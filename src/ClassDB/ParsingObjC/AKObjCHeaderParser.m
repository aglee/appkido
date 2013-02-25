/*
 * AKObjCHeaderParser.m
 *
 * Created by Andy Lee on Fri Jun 28 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKObjCHeaderParser.h"

#import "DIGSLog.h"

#import "AKDatabase.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKCategoryNode.h"
#import "AKMethodNode.h"

#pragma mark -
#pragma mark Character test functions

// We only care about certain punctuation characters.  This isn't
// full-blown Objective-C parsing.
static BOOL isPunctuation(char c)
{
    return ((c == '{') || (c == '}')
            || (c == '(') || (c == ')')
            || (c == '<') || (c == '>')
            || (c == ';') || (c == ':') || (c == ',')
            || (c == '-') || (c == '+'));
}

@implementation AKObjCHeaderParser

#pragma mark -
#pragma mark DIGSFileProcessor methods

- (BOOL)shouldProcessFile:(NSString *)filePath
{
    return [[filePath pathExtension] isEqualToString:@"h"];
}

#pragma mark -
#pragma mark AKParser methods

- (void)parseCurrentFile
{
    // Keep parsing until we run out of top-level nodes.
    while (([self _parseTopLevelNode]))
    {
    }
}

#pragma mark -
#pragma mark Private methods -- parsing

// Consumes tokens until we see either either an "@interface" or a
// "@protocol" declaration.  Parses the thing being declared -- either a
// class, a category, or a protocol.  Or nil.
- (BOOL)_parseTopLevelNode
{
    char token[AKParserTokenBufferSize];

    while (([self _parseTokenIntoBuffer:token]))
    {
        if (strcmp(token, "@interface") == 0)
        {
            [self _parseClassOrCategoryDeclaration];
            return YES;
        }
        else if (strcmp(token, "@protocol") == 0)
        {
            [self _parseProtocolDeclaration];
            return YES;
        }
    }

    // If we got this far, we've exhausted the input.
    return NO;
}

// On entry, we've just consumed an @interface token, which means we're
// sitting on a class name.  We are inside either a class declaration
// or a category declaration, but we won't know which until we've parsed
// a few tokens.
//
// Note that curly braces are optional if a class doesn't declare ivars.
//
// Consumes the @end token that closes the class or category declaration.
- (void)_parseClassOrCategoryDeclaration
{
    char token[AKParserTokenBufferSize];

    // Get or create the class node whose name is the class name we are
    // sitting on.
    (void)[self _parseTokenIntoBuffer:token];
    NSString *className = [NSString stringWithUTF8String:token];
    AKClassNode *classNode = [[self targetDatabase] classWithName:className];

    if (!classNode)
    {
        classNode = [AKClassNode nodeWithNodeName:className
                                         database:[self targetDatabase]
                                    frameworkName:[self targetFrameworkName]];
    }
    [[self targetDatabase] addClassNode:classNode];

    AKBehaviorNode *resultNode = nil;
    while (([self _parseTokenIntoBuffer:token]))
    {
        if (strcmp(token, "@end") == 0)
        {
            break;
        }
        else if (strcmp(token, "@property") == 0)
        {
            // Skip the rest of the line so that the opening paren in the property
            // declaration doesn't fool us into thinking we're looking at a category.
            // [agl] I'm assuming the whole property declaration is on one line so
            // that I can use this quicker approach rather than scan to the semicolon.
            [self _skipRemainderOfLine];
        }
        else if (strcmp(token, ":") == 0)
        {
            // We now know we are parsing a class declaration, because
            // we've come across the specification of its superclass.
            (void)[self _parseTokenIntoBuffer:token];
            NSString *parentClassName = [NSString stringWithUTF8String:token];
            AKClassNode *parentClassNode = [[self targetDatabase] classWithName:parentClassName];

            if (!parentClassNode)
            {
                parentClassNode = [AKClassNode nodeWithNodeName:parentClassName
                                                       database:[self targetDatabase]
                                                  frameworkName:[self targetFrameworkName]];
                [[self targetDatabase] addClassNode:parentClassNode];
            }

            // [agl] KLUDGE  Some .h files use #ifndef WIN32 to decide
            // which declaration of a class to use.  Since our parsing
            // does not handle macros, we will see the same class declared
            // twice.  The nil check ensures that this doesn't cause us to
            // add a class twice to its superclass.  We stick with the
            // first declaration we encounter, since it looks like this is
            // always the #ifndef WIN32 case.
            if ([classNode parentClass] == nil)
            {
                [parentClassNode addChildClass:classNode];
            }

            resultNode = classNode;
        }
        else if (strcmp(token, "(") == 0)
        {
            // We now know we are parsing a category declaration, because
            // we've come across the specification of the category name.
            (void)[self _parseTokenIntoBuffer:token];
            NSString *catName = [NSString stringWithUTF8String:token];
            AKCategoryNode *categoryNode = [classNode categoryNamed:catName];

            if (categoryNode == nil)
            {
                categoryNode = [AKCategoryNode nodeWithNodeName:catName
                                                       database:[self targetDatabase]
                                                  frameworkName:[self targetFrameworkName]];
                [classNode addCategory:categoryNode];
            }

            [self _skipPastClosingParen];
            resultNode = categoryNode;
        }
        else if (strcmp(token, "<") == 0)
        {
            // We've come across a declaration of protocols conformed to
            // by the ThingWeAreParsing.
            if (resultNode == nil)
            {
                // If we haven't determined what we're parsing by now,
                // we must be parsing a class.
                resultNode = classNode;
            }

            [self _parseProtocolListFor:resultNode];
        }
        else if (strcmp(token, "{") == 0)
        {
            // We now know we are parsing a class declaration, because
            // we've come across the declaration of its ivars.
            resultNode = classNode;
            [self _skipPastClosingBrace];
        }
        else if (strcmp(token, "+") == 0)
        {
            // If we haven't determined what we're parsing by now,
            // we must be parsing a class and not a category.
            if (resultNode == nil)
            {
                resultNode = classNode;
            }

            // We've come across the declaration of a class method.
            // Note: I'm adding the method to the class node even if
            // resultNode is a category node.
            [self _parseMethodDeclarationFor:classNode
                             blockForGetting:blockForGettingMemberNode(classMethodWithName)
                              blockForAdding:blockForAddingMemberNode(addClassMethod)];
        }
        else if (strcmp(token, "-") == 0)
        {
            // If we haven't determined what we're parsing by now,
            // we must be parsing a class and not a category.
            if (resultNode == nil)
            {
                resultNode = classNode;
            }

            // We've come across the declaration of an instance method.
            // Note: I'm adding the method to the class node even if
            // resultNode is a category node.
            [self _parseMethodDeclarationFor:classNode
                             blockForGetting:blockForGettingMemberNode(instanceMethodWithName)
                              blockForAdding:blockForAddingMemberNode(addInstanceMethod)];
        }
    }

    if (resultNode == classNode)
    {
        [classNode setHeaderFileWhereDeclared:[self currentPath]];

        // Make sure the framework which the class's .h file lives in is
        // recognized as the node's main framework.
        [classNode setOwningFrameworkName:[self targetFrameworkName]];
    }
}

// Assumes we've already consumed the @protocol token and we're looking
// at a protocol name.
//
// Consumes the @end token that closes the protocol declaration -- or the
// semicolon that closes it, if it's a forward declaration.
//
// Logic is similar to -_parseClassOrCategoryDeclaration, except there
// are fewer cases to consider and we know we are returning an
// AKProtocolNode.
- (void)_parseProtocolDeclaration
{
    char token[AKParserTokenBufferSize];
    (void)[self _parseTokenIntoBuffer:token];
    NSString *protocolName = [NSString stringWithUTF8String:token];
    AKProtocolNode *resultNode = [[self targetDatabase] protocolWithName:protocolName];

    if (!resultNode)
    {
        resultNode = [AKProtocolNode nodeWithNodeName:protocolName
                                             database:[self targetDatabase]
                                        frameworkName:[self targetFrameworkName]];
        [[self targetDatabase] addProtocolNode:resultNode];
    }

    [resultNode setHeaderFileWhereDeclared:[self currentPath]];

    while (([self _parseTokenIntoBuffer:token]))
    {
        if (strcmp(token, ";") == 0)
        {
            // If we see a semicolon we must be looking at a forward
            // declaration of the protocol.  Otherwise the semicolon
            // would have been consumed elsewhere in this loop.
            return;
        }
        else if (strcmp(token, "@end") == 0)
        {
            return;
        }
        else if (strcmp(token, "<") == 0)
        {
            [self _parseProtocolListFor:resultNode];
        }
        else if (strcmp(token, "+") == 0)
        {
            // We've come across the declaration of a class method.
            [self _parseMethodDeclarationFor:resultNode
                             blockForGetting:blockForGettingMemberNode(classMethodWithName)
                              blockForAdding:blockForAddingMemberNode(addClassMethod)];
        }
        else if (strcmp(token, "-") == 0)
        {
            // We've come across the declaration of an instance method.
            [self _parseMethodDeclarationFor:resultNode
                             blockForGetting:blockForGettingMemberNode(instanceMethodWithName)
                              blockForAdding:blockForAddingMemberNode(addInstanceMethod)];
        }
    }
}

// Assumes opening angle-bracket has already been consumed.
// Consumes the closing angle-bracket.
- (void)_parseProtocolListFor:(AKBehaviorNode *)behaviorNode
{
    char token[AKParserTokenBufferSize];

    while (([self _parseTokenIntoBuffer:token]))
    {
        if (strcmp(token, ">") == 0)
        {
            return;
        }
        else if (strcmp(token, ",") == 0)
        {
            continue;
        }
        else
        {
            NSString *protocolName = [NSString stringWithUTF8String:token];
            AKProtocolNode *protocolNode = [[self targetDatabase] protocolWithName:protocolName];

            if (!protocolNode)
            {
                protocolNode = [AKProtocolNode nodeWithNodeName:protocolName
                                                       database:[self targetDatabase]
                                                  frameworkName:[self targetFrameworkName]];
                [[self targetDatabase] addProtocolNode:protocolNode];
            }

            [behaviorNode addImplementedProtocol:protocolNode];
        }
    }
}

// Assumes we are at the start of a method declaration.
//
// Consumes the closing semicolon.
//
// This logic handles variable arg lists just fine; it omits the trailing
// comma and ellipsis.
- (void)_parseMethodDeclarationFor:(AKBehaviorNode *)behaviorNode
                   blockForGetting:(AKBlockForGettingMemberNode)getMemberNode
                    blockForAdding:(AKBlockForAddingMemberNode)addMemberNode
{
    // We append to methodName a token at a time, as we discover the
    // parts of the method signature.  When we've reached the semicolon
    // at the end of the method declaration (i.e., a semicolon),
    // methodName will contain the complete name of the method.
    NSMutableString *methodName = [NSMutableString stringWithCapacity:128];
    NSMutableArray *argTypes = [NSMutableArray array];

    // Process all tokens in the method declaration.
    char token[AKParserTokenBufferSize];

    while (([self _parseTokenIntoBuffer:token]))
    {
        if (strcmp(token, ";") == 0)
        {
            AKMethodNode *methodNode = getMemberNode(behaviorNode, methodName);

            if (methodNode == nil)
            {
                methodNode = [[[AKMethodNode alloc] initWithNodeName:methodName
                                                            database:[self targetDatabase]
                                                       frameworkName:[self targetFrameworkName]
                                                      owningBehavior:behaviorNode]
                              autorelease];
                addMemberNode(behaviorNode, methodNode);
            }

            [methodNode setArgumentTypes:argTypes];

            return;
        }
        else if (strcmp(token, "(") == 0)
        {
            // We've encountered the method's return type.  Skip it.
            [self _skipJunk];
            [self _skipPastClosingParen];
        }
        else if (strcmp(token, ":") == 0)
        {
            // We've encountered the colon just before a method argument.
            // We are looking at either ":(argType)argName" or just
            // ":argName" with an implicit argument type of id.  Either
            // way, add the colon to the method name.
            [methodName appendString:@":"];

            char argTok[AKParserTokenBufferSize];
            (void)[self _parseTokenIntoBuffer:argTok];
            if (strcmp(argTok, "(") != 0)
            {
                // We're looking at the arg name, so the implicit arg
                // type is id.  Ignore the arg name itself.
                [argTypes addObject:@"id"];
            }
            else
            {
                // We're looking at the arg type.  Parse it.  Note that
                // an arg type may consist of two tokens that can't
                // just be concatenated, such as "unsigned int".  So
                // put a space between each of the tokens that make up
                // the arg type.
                NSMutableString *argType = [NSMutableString string];

                (void)[self _parseTokenIntoBuffer:argTok];
                while (strcmp(argTok, ")") != 0)
                {
                    if ([argType length] > 0)
                    {
                        [argType appendString:@" "];
                    }

                    [argType appendString:[NSString stringWithUTF8String:argTok]];
                    (void)[self _parseTokenIntoBuffer:argTok];
                }
                [argTypes addObject:argType];

                // Skip the arg name.
                (void)[self _parseTokenIntoBuffer:argTok];
            }
        }
        else
        {
            // Check whether the token we're looking at could be a component of
            // the method name (either the first component, which need not be
            // followed by a colon, or some component after the first, which
            // must be).  Otherwise, we've probably encountered something like
            // the DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER macro that's in
            // NSATSTypesetter.h.  Or possibly the comma and ellipsis in a
            // method that takes varargs.
            if (([methodName length] == 0) || ((_current < _dataEnd) && (*_current == ':')))
            {
                [methodName appendString:[NSString stringWithUTF8String:token]];
            }
        }
    }

    // If we got this far, there was either a syntax error or our parsing
    // logic is wrong.
    DIGSLogError(@"shouldn't have gotten this far");
}

- (BOOL)_parseTokenIntoBuffer:(char[AKParserTokenBufferSize])buffer
{
    const char *tokenStart;

    // Skip non-token characters.
    [self _skipJunk];
    if (_current >= _dataEnd)
    {
        return NO;
    }

    // Handle the case of a punctuation token (a single special character
    // that need not be delimited by whitespace).
    if (isPunctuation(*_current))
    {
        buffer[0] = *_current;
        buffer[1] = '\0';
        _current++;
        return YES;
    }

    // If we got this far, we must have a non-punctuation token.
    tokenStart = _current;
    [self _skipPastEndOfToken];
    if (_current == tokenStart)
    {
        return NO;
    }

    NSInteger len = _current - tokenStart;

    memcpy(buffer, tokenStart, len);
    buffer[len] = '\0';
    return YES;
}


#pragma mark -
#pragma mark Private methods -- skipping

// Skips whitespace, comments, and preprocessor directives.
- (void)_skipJunk
{
    [self _skipWhitespace];
    while (_current < _dataEnd)
    {
        switch (*_current)
        {
            case '/': // We found a comment.
            {
                _current++;
                if (*_current == '/') // It's a slash-slash comment.
                {
                    _current++;
                    [self _skipRemainderOfLine];
                }
                else if (*_current == '*') // It's a slash-star comment.
                {
                    _current++;
                    while ((*_current != '*') || (*(_current + 1) != '/'))
                    {
                        _current++;
                    }
                    _current += 2;
                }
                else // FIXME [agl] handle error
                {
                }
                [self _skipWhitespace];
            }
            break;
            case '#': // preprocessor directive
            {
                [self _skipRemainderOfLine];
                [self _skipWhitespace];
            }
            break;
            default: // found beginning of a token we care about
            {
                return;
            }
        }
    }
}

- (void)_skipRemainderOfLine
{
    while (_current < _dataEnd)
    {
        // [agl] not exactly right for \n\r line endings, but ok
        if ((*_current == '\n') || (*_current == '\r'))
        {
            return;
        }
        _current++;
    }
}

- (void)_skipWhitespace
{
    while (_current < _dataEnd)
    {
        if (!isspace(*_current))
        {
            return;
        }
        _current++;
    }
}

// Moves to next occurrence of whitespace, punctuation, or end-of-data.
- (void)_skipPastEndOfToken
{
    while (_current < _dataEnd)
    {
        if (isspace(*_current) || isPunctuation(*_current))
        {
            return;
        }
        _current++;
    }
}

// Assumes we have already consumed the opening brace.
// Consumes the closing brace.
- (void)_skipPastClosingBrace
{
    char buffer[AKParserTokenBufferSize];

    while (([self _parseTokenIntoBuffer:buffer]))
    {
        if (strcmp(buffer, "}") == 0)
        {
            return;
        }
        else if (strcmp(buffer, "{") == 0)
        {
            [self _skipPastClosingBrace];
        }
    }
}

// Assumes we have already consumed the opening paren.
// Consumes the closing paren.
- (void)_skipPastClosingParen
{
    char buffer[AKParserTokenBufferSize];

    while (([self _parseTokenIntoBuffer:buffer]))
    {
        if (strcmp(buffer, ")") == 0)
        {
            return;
        }
        else if (strcmp(buffer, "(") == 0)
        {
            [self _skipPastClosingParen];
        }
    }
}

@end
