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
    return [filePath.pathExtension isEqualToString:@"h"];
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

// On entry, we've just consumed an "@interface" token, which means we're
// sitting on a class name. We are inside either a class declaration or a
// category declaration; we won't know which until we've parsed a few tokens.
//
// [agl] I add methods to the class node even if they're declared in a category.
// I suppose I could add to both, but we never really use AKCategoryNode, so it
// doesn't matter.
//
// Consumes the @end token that closes the class or category declaration.
- (void)_parseClassOrCategoryDeclaration
{
    char token[AKParserTokenBufferSize];

    // Parse the class name and get or create the node for it.
    (void)[self _parseTokenIntoBuffer:token];
    NSString *className = @(token);
    AKClassNode *classNode = [self.targetDatabase classWithName:className];

    if (!classNode)
    {
        // Pass nil for the class's owning framework, because we don't know yet
        // whether we are parsing a class declaration. It's possible this is a
        // category declaration and the category's class belongs to a different
        // framework. We will set the class's real owning framework when we know
        // we're parsing the class declaration.
        classNode = [AKClassNode nodeWithNodeName:className
                                         database:self.targetDatabase
                                    frameworkName:nil];
        [self.targetDatabase addClassNode:classNode];
    }

    // Assume we're parsing a class declaration unless and until we learn it's a
    // category declaration.
    AKBehaviorNode *resultNode = classNode;

    // If we're sitting on the declaration of a superclass, parse it.
    [self _skipJunk];
    if (*_current == ':')
    {
        [self _parseSuperclassNameForClassNode:classNode];
    }

    // If we're sitting on the declaration of a category name, parse it, and
    // note that we're parsing a category and not a class.
    [self _skipJunk];
    if (*_current == '(')
    {
        resultNode = [self _parseCategoryNameForClassNode:classNode];
    }

    // If we're sitting on a list of protocol names, parse it.
    [self _skipJunk];
    if (*_current == '<')
    {
        _current++;

        NSArray *implementedProtocols = [self _parseProtocolList];

        [classNode addImplementedProtocols:implementedProtocols];

        if (resultNode != classNode)
        {
            [resultNode addImplementedProtocols:implementedProtocols];
        }
    }

    // Parse method declarations and ignore everything else.
    //
    // We "fast forward" in a few special cases, to minimize the possibility of
    // seeing a stray "-" or "+" and confusing it for a method declaration. For
    // example, it's possible for an enum to be declared with a negative number;
    // by fast-forwarding over the {}, we avoid being confused by the "-".
    while (([self _parseTokenIntoBuffer:token]))
    {
        if (strcmp(token, "@end") == 0)
        {
            break;
        }
        else if (strcmp(token, "@property") == 0)
        {
            [self _skipPastTerminatingSemicolon];
        }
        else if (strcmp(token, "#define") == 0)
        {
            // [agl] Might be multi-line macro.
            [self _skipRemainderOfLine];
        }
        else if (strcmp(token, "(") == 0)
        {
            [self _skipPastClosingParen];
        }
        else if (strcmp(token, "{") == 0)
        {
            [self _skipPastClosingBrace];
        }
        else if (strcmp(token, "+") == 0)
        {
            // Parse the declaration of a class method.
            [self _parseMethodDeclarationFor:classNode
                             blockForGetting:blockForGettingMemberNode(classMethodWithName)
                              blockForAdding:blockForAddingMemberNode(addClassMethod)];
        }
        else if (strcmp(token, "-") == 0)
        {
            // Parse the declaration of an instance method.
            [self _parseMethodDeclarationFor:classNode
                             blockForGetting:blockForGettingMemberNode(instanceMethodWithName)
                              blockForAdding:blockForAddingMemberNode(addInstanceMethod)];
        }
    }

    if (resultNode == classNode)
    {
        classNode.headerFileWhereDeclared = self.currentPath;
        classNode.nameOfOwningFramework = self.targetFrameworkName;
    }
}

// Assumes we're sitting on the ":" that indicates we're about to declare the
// class's superclass.
- (void)_parseSuperclassNameForClassNode:(AKClassNode *)classNode
{
    char token[AKParserTokenBufferSize];
    
    // Skip past the ':'.
    _current++;

    // Parse the superclass name and get or create the node for it.
    (void)[self _parseTokenIntoBuffer:token];
    NSString *parentClassName = @(token);
    AKClassNode *parentClassNode = [self.targetDatabase classWithName:parentClassName];

    if (!parentClassNode)
    {
        parentClassNode = [AKClassNode nodeWithNodeName:parentClassName
                                               database:self.targetDatabase
                                          frameworkName:self.targetFrameworkName];
        [self.targetDatabase addClassNode:parentClassNode];
    }

    // Connect the class to its superclass.
    // [agl] KLUDGE  Some .h files use #ifndef WIN32 to decide
    // which declaration of a class to use.  Since our parsing
    // does not handle macros, we will see the same class declared
    // twice.  The nil check ensures that this doesn't cause us to
    // add a class twice to its superclass.  We stick with the
    // first declaration we encounter, since it looks like this is
    // always the #ifndef WIN32 case.
    if (classNode.parentClass == nil)
    {
        [parentClassNode addChildClass:classNode];
    }
}

// Assumes we're sitting on the "(" that begins a category name declaration.
// The category name might be empty, indicating a class extension. Skips past
// the closing ")".
- (AKCategoryNode *)_parseCategoryNameForClassNode:(AKClassNode *)classNode
{
    char token[AKParserTokenBufferSize];
    
    // Skip past the opening paren.
    _current++;

    // The next token will be either be a category name or, in the case of a
    // class extension, the closing ")". We treat a class extension as a
    // category whose name is @"".
    (void)[self _parseTokenIntoBuffer:token];
    NSString *categoryName;
    if (strcmp(token, ")") == 0)
    {
        categoryName = @"";
    }
    else
    {
        categoryName = @(token);
        [self _skipPastClosingParen];
    }

    // Parse the category name and get or create the node for it.
    AKCategoryNode *categoryNode = [classNode categoryNamed:categoryName];

    if (categoryNode == nil)
    {
        categoryNode = [AKCategoryNode nodeWithNodeName:categoryName
                                               database:self.targetDatabase
                                          frameworkName:self.targetFrameworkName];
        [classNode addCategory:categoryNode];
    }

    return categoryNode;
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
    NSString *protocolName = @(token);
    AKProtocolNode *resultNode = [self.targetDatabase protocolWithName:protocolName];

    if (!resultNode)
    {
        resultNode = [AKProtocolNode nodeWithNodeName:protocolName
                                             database:self.targetDatabase
                                        frameworkName:self.targetFrameworkName];
        [self.targetDatabase addProtocolNode:resultNode];
    }

    resultNode.headerFileWhereDeclared = self.currentPath;

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
        else if (strcmp(token, "@property") == 0)
        {
            [self _skipPastTerminatingSemicolon];
        }
        else if (strcmp(token, "<") == 0)
        {
            NSArray *implementedProtocols = [self _parseProtocolList];

            [resultNode addImplementedProtocols:implementedProtocols];
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
- (NSArray *)_parseProtocolList
{
    NSMutableArray *implementedProtocols = [NSMutableArray array];
    
    char token[AKParserTokenBufferSize];

    while (([self _parseTokenIntoBuffer:token]))
    {
        if (strcmp(token, ">") == 0)
        {
            break;
        }
        else if (strcmp(token, ",") == 0)
        {
            continue;
        }
        else
        {
            NSString *protocolName = @(token);
            AKProtocolNode *protocolNode = [self.targetDatabase protocolWithName:protocolName];

            if (!protocolNode)
            {
                // Pass nil as the protocol's framework name. We will set its
                // real framework name when we encounter the @protocol
                // declaration.
                protocolNode = [AKProtocolNode nodeWithNodeName:protocolName
                                                       database:self.targetDatabase
                                                  frameworkName:nil];
                [self.targetDatabase addProtocolNode:protocolNode];
            }

            [implementedProtocols addObject:protocolNode];
        }
    }

    return implementedProtocols;
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
                methodNode = [[AKMethodNode alloc] initWithNodeName:methodName
                                                            database:self.targetDatabase
                                                       frameworkName:self.targetFrameworkName
                                                      owningBehavior:behaviorNode];
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
                    if (argType.length > 0)
                    {
                        [argType appendString:@" "];
                    }

                    [argType appendString:@(argTok)];
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
            if ((methodName.length == 0) || ((_current < _dataEnd) && (*_current == ':')))
            {
                [methodName appendString:@(token)];
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

// Assumes we are on a semicolon-terminated statement.
- (void)_skipPastTerminatingSemicolon
{
    char buffer[AKParserTokenBufferSize];

    while (([self _parseTokenIntoBuffer:buffer]))
    {
        if (strcmp(buffer, ";") == 0)
        {
            return;
        }
    }
}

// Skips to the end of the line, which may be the current position.
// Does *not* consume the newline/return character if one is found.
- (void)_skipRemainderOfLine
{
    while (_current < _dataEnd)
    {
        if ((*_current == '\n') || (*_current == '\r'))
        {
            return;
        }
        _current++;
    }
}

// Skips to the next whitespace character, which may be the current character.
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
