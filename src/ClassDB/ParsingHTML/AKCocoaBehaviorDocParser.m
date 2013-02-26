/*
 * AKCocoaBehaviorDocParser.m
 *
 * Created by Andy Lee on Thu Jun 05 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKCocoaBehaviorDocParser.h"

#import "DIGSLog.h"

#import "AKClassNode.h"
#import "AKDatabase.h"
#import "AKFileSection.h"
#import "AKHTMLConstants.h"
#import "AKMethodNode.h"
#import "AKNotificationNode.h"
#import "AKPropertyNode.h"
#import "AKProtocolNode.h"
#import "AKTextUtils.h"

@implementation AKCocoaBehaviorDocParser

#pragma mark -
#pragma mark AKDocParser methods

- (void)applyParseResults
{
    [self _parseMethodsAndProperties];

    // Parse the "Constants" section if there is one. <== [agl] I see this comment -- where is it actually done?
    [super applyParseResults];
}

#pragma mark -
#pragma mark Private methods

- (void)_parseMethodsAndProperties
{
    // If there is a "Programming Topics" minor section, raise it to the
    // level of a major section so it will get listed in the doc list.
    [self _tweakRootSection];

    // Are we looking at a class's doc file or a protocol's or neither?
    // Retrieve or create an AKClassNode or AKProtocolNode accordingly.
    AKBehaviorNode *behaviorNode = nil;
    BOOL isMainClassReference = NO;

    if ([self _currentFileIsClassReference:&isMainClassReference])
    {
        AKClassNode *classNode = [self _classForRootSection];

        if (classNode == nil)
        {
            return;
        }

        // Store bits of information about the class node relating it to its
        // HTML documentation file.
        [[self targetDatabase] rememberThatClass:classNode
                    isDocumentedInHTMLFile:[self currentPath]];

        if (isMainClassReference)
        {
            [classNode setNodeDocumentation:_rootSectionOfCurrentFile];
            [classNode setNameOfOwningFramework:[self targetFrameworkName]];
        }

        [classNode associateDocumentation:_rootSectionOfCurrentFile
                       withFrameworkNamed:[self targetFrameworkName]];

        behaviorNode = classNode;
    }
    else if ([self _currentFileIsProtocolReference])
    {
        AKProtocolNode *protocolNode = [self _protocolForRootSection];

        if (protocolNode == nil)
        {
            return;
        }
        
        // Store bits of information about the protocol node relating it to its
        // HTML documentation file.
        [[self targetDatabase] rememberThatProtocol:protocolNode
                       isDocumentedInHTMLFile:[self currentPath]];

        [protocolNode setNodeDocumentation:_rootSectionOfCurrentFile];
        [protocolNode setNameOfOwningFramework:[self targetFrameworkName]];

        behaviorNode = protocolNode;
    }
    else
    {
        return;
    }

    // If we got this far, we are looking at docs for a class or protocol. Add
    // method nodes for the methods documented in the file. There are two cases:
    // either the file contains deprecated methods or it contains regular
    // un-deprecated methods.
    if ([self _currentFileIsDeprecatedMethodsFile])
    {
        [self _addDeprecatedMethodsToBehaviorNode:behaviorNode];
    }
    else
    {
        [self _addMethodsToBehaviorNode:behaviorNode];
    }
}

// [agl] KLUDGE -- If there is a "Programming Topics" minor section, raise
// it to the level of a major section so it will get listed in the doc list.
- (void)_tweakRootSection
{
    NSInteger numMajorSections = [_rootSectionOfCurrentFile numberOfChildSections];
    NSInteger majorIndex;

    for (majorIndex = 0; majorIndex < numMajorSections; majorIndex++)
    {
        AKFileSection *majorSection = [_rootSectionOfCurrentFile childSectionAtIndex:majorIndex];
        NSString *majorSectionName = [majorSection sectionName];

        if ([majorSectionName isEqualToString:@"Programming Topics"])
        {
            // There is a "Programming Topics" section, but it is
            // already a major section, so we're done.
            return;
        }

        NSInteger numMinorSections = [majorSection numberOfChildSections];
        NSInteger minorIndex;

        for (minorIndex = 0; minorIndex < numMinorSections; minorIndex++)
        {
            AKFileSection *minorSection = [majorSection childSectionAtIndex:minorIndex];
            NSString *minorSectionName = [minorSection sectionName];

            if ([minorSectionName isEqualToString:@"Programming Topics"])
            {
                // Found a "Programming Topics" section, and it's
                // a minor item; raise it to the level of a major item.
                // Make sure to do the insert before the remove, so
                // minorSection doesn't get dealloc'ed.
                [_rootSectionOfCurrentFile insertChildSection:minorSection
                                                      atIndex:(majorIndex + 1)];
                [majorSection removeChildSectionAtIndex:minorIndex];
                return;
            }
        }
    }
}

- (BOOL)_currentFileIsClassReference:(BOOL *)isMainClassReference
{
    // Exclude table-of-contents files, which can look deceptively like class
    // doc files.
    if ([[self currentPath] hasSuffix:@"toc.html"])
    {
        *isMainClassReference = NO;
        return NO;
    }

    // See if the current file contains methods added to a class by a framework
    // other than the class's main framework, like the NSAttributedString
    // methods added by AppKit.
    if ([[_rootSectionOfCurrentFile sectionName] hasSuffix:@"Additions Reference"]
        || [[_rootSectionOfCurrentFile sectionName] hasSuffix:@"Additions"])
    {
        *isMainClassReference = NO;
        return YES;
    }

    // See if the current file is a "Deprecated Methods" file.  Files of this
    // form were added in the Feb 2007 update (maybe earlier, I haven't checked).
    if ([self _currentFileIsDeprecatedMethodsFile])
    {
        *isMainClassReference = NO;
        return YES;
    }

    // Assume we have a class's main doc file if its root section is named
    // "Class Reference" or "Class Objective-C Reference".
    NSString *rootSectionName = [_rootSectionOfCurrentFile sectionName];
    if ([rootSectionName hasSuffix:@"Class Reference"]
        || [rootSectionName hasSuffix:@"Class Objective-C Reference"])
    {
        *isMainClassReference = YES;
        return YES;
    }

    // Assume we have a class's main doc file if it has a major section named
    // "Class Description".
    if ([_rootSectionOfCurrentFile hasChildSectionWithName:AKClassDescriptionHTMLSectionName])
    {
        *isMainClassReference = YES;
        return YES;
    }

    // Assume we have a class's main doc file if it's somewhere in a ...Classes
    // directory and the file name matches the name of the root section.
    NSString *filenameSansExtension = [[[self currentPath] lastPathComponent] stringByDeletingPathExtension];

    if ([[self currentPath] ak_contains:@"Classes"]
        && [rootSectionName isEqualToString:filenameSansExtension])
    {
        *isMainClassReference = YES;
        return YES;
    }

    return NO;
}

- (BOOL)_currentFileIsProtocolReference
{
    // Assume we have a protocol's doc file if its root section is named
    // "Protocol Reference" or "Protocol Objective-C Reference".
    if ([[_rootSectionOfCurrentFile sectionName] hasSuffix:@"Protocol Reference"]
        || [[_rootSectionOfCurrentFile sectionName] hasSuffix:@"Protocol Objective-C Reference"])
    {
        return YES;
    }
    
    // Assume we have a protocol's doc file if it has a major section named
    // "Protocol Description".
    if ([_rootSectionOfCurrentFile hasChildSectionWithName:AKProtocolDescriptionHTMLSectionName])
    {
        return YES;
    }
    
    // Assume we have a protocol's doc file if it's somewhere in a ...Protocols
    // directory and the file name matches the name of the root section.
    NSString *rootSectionName = [_rootSectionOfCurrentFile sectionName];
    NSString *filenameSansExtension = [[[self currentPath] lastPathComponent] stringByDeletingPathExtension];
    
    if ([[self currentPath] ak_contains:@"Protocols"]
        && [rootSectionName isEqualToString:filenameSansExtension])
    {
        return YES;
    }

    return NO;
}

- (BOOL)_currentFileIsDeprecatedMethodsFile
{
    return [[self currentPath] ak_contains:@"Deprecat"];
}

- (NSString *)_parseBehaviorName
{
    NSArray *partsOfTitle = [[_rootSectionOfCurrentFile sectionName] componentsSeparatedByString:@" "];
    
    if ([partsOfTitle count] == 0)
    {
        return nil;
    }
    else if ([partsOfTitle count] > 1 && [[partsOfTitle objectAtIndex:0] isEqualToString:@"Deprecated"])
    {
        return [partsOfTitle objectAtIndex:1];
    }
    else
    {
        return [partsOfTitle objectAtIndex:0];
    }
}

- (AKClassNode *)_classForRootSection
{
    // Get our hands on the node for the class whose documentation is
    // in _rootSectionOfCurrentFile.
    NSString *className = [self _parseBehaviorName];
    AKClassNode *classNode = [[self targetDatabase] classWithName:className];

    // We assume the database has already been populated from header files.
    // If a class isn't already in the database, we assume it's an accident
    // that we've come across the class's doc file.  Case in point: in the
    // Feb 2007 docs, the QuartzFramework doc directory contains docs for *two*
    // frameworks: PDFKit (thus PDF*.html) and QuartzComposer (thus QC*.html).

//    if (!classNode)
//    {
//        classNode = [AKClassNode nodeWithNodeName:className owningFrameworkName:_frameworkName];
//    }
//    [[self targetDatabase] addClassNode:classNode];

    return classNode;
}

- (AKProtocolNode *)_protocolForRootSection
{
// May06 -- In the May06 docs, the top-level headings for protocol doc
// files can contain multiple words, like the class doc files.  I should
// have been handling this anyway, May06 aside.
//    NSString *protocolName = [_rootSectionOfCurrentFile sectionName];
    NSString *protocolName = [self _parseBehaviorName];

    AKProtocolNode *protocolNode = [[self targetDatabase] protocolWithName:protocolName];

    // We assume the database has already been populated from header files.
    // [agl] FIXME -- I don't like this assumption -- presumes class knows
    // order in which it is used.
    // This means we've seen all the *formal* protocols we're going to see.
    // However, it's possible we're looking at the doc for an *informal* protocol.
    if (!protocolNode)
    {
        protocolNode = [AKProtocolNode nodeWithNodeName:protocolName
                                               database:[self targetDatabase]
                                          frameworkName:[self targetFrameworkName]];
        [[self targetDatabase] addProtocolNode:protocolNode];
    }

    return protocolNode;
}

- (void)_addMembersFromMajorSection:(NSString *)htmlSectionName
                     toBehaviorNode:(AKBehaviorNode *)behaviorNode
               usingMemberNodeClass:(Class)memberNodeClass
                    blockForGetting:(AKBlockForGettingMemberNode)getMemberNode
                     blockForAdding:(AKBlockForAddingMemberNode)addMemberNode
{
    AKFileSection *majorSection = [_rootSectionOfCurrentFile childSectionWithName:htmlSectionName];

    for (AKFileSection *minorSection in [majorSection childSections])
    {
        NSString *memberName = [minorSection sectionName];
        AKMemberNode *memberNode = getMemberNode(behaviorNode, memberName);
        
        if (memberNode == nil)
        {
            memberNode = [[[memberNodeClass alloc] initWithNodeName:memberName
                                                           database:[self targetDatabase]
                                                      frameworkName:[self targetFrameworkName]
                                                     owningBehavior:behaviorNode]
                          autorelease];
            addMemberNode(behaviorNode, memberNode);
        }

        if ([memberNode nodeDocumentation] != nil)
        {
            DIGSLogWarning(@"trying to set documentation twice for node %@", memberNode);
        }
        else
        {
            [memberNode setNodeDocumentation:minorSection];
        }
    }
}

// Unlike the main doc file for a class, a "Deprecated ... Methods" file lumps
// all methods into one major section.  We have to guess whether each method
// is a class method, instance method, or delegate method.  I'm *assuming*
// notifications won't be in the file.
//
// NOTE: The logic in this method assumes we've already parsed the headers and
// populated the database with all the class method and instance method nodes
// we're ever going to see.
- (void)_addDeprecatedMethodsToBehaviorNode:(AKBehaviorNode *)behaviorNode
{
    // Look for major sections that contain method docs.  There can be more
    // than one -- e.g., "Deprecated in Mac OS X v10.3" and
    // "Deprecated in Mac OS X v10.4".
    for (AKFileSection *majorSection in [_rootSectionOfCurrentFile childSections])
    {
        if ([[majorSection sectionName] hasPrefix:@"Deprecated in"])
        {
            // Add each of the methods in the major section to the behavior node.
            for (AKFileSection *minorSection in [majorSection childSections])
            {
                NSString *methodName = [minorSection sectionName];
                AKMethodNode *methodNode = [behaviorNode addDeprecatedMethodIfAbsentWithName:methodName
                                                                               frameworkName:[self targetFrameworkName]];
                if (methodNode != nil)
                {
                    [methodNode setNodeDocumentation:minorSection];
                }
            }
        }
    }
}

// Class and protocol doc files usually group all class methods into one
// major section, instance methods into another, etc.  The exception (as of
// now) is "Deprecated (classname) Methods" files, which should be processed
// by _addDeprecatedMethodsToBehaviorNode: rather than this method.
- (void)_addMethodsToBehaviorNode:(AKBehaviorNode *)behaviorNode
{
    // Add property nodes.
    [self _addMembersFromMajorSection:AKPropertiesHTMLSectionName
                       toBehaviorNode:behaviorNode
                 usingMemberNodeClass:[AKPropertyNode class]
                      blockForGetting:blockForGettingMemberNode(propertyNodeWithName)
                       blockForAdding:blockForAddingMemberNode(addPropertyNode)];

    // Add class method nodes.
    [self _addMembersFromMajorSection:AKClassMethodsHTMLSectionName
                       toBehaviorNode:behaviorNode
                 usingMemberNodeClass:[AKMethodNode class]
                      blockForGetting:blockForGettingMemberNode(classMethodWithName)
                       blockForAdding:blockForAddingMemberNode(addClassMethod)];

    // Add instance method nodes.
    [self _addMembersFromMajorSection:AKInstanceMethodsHTMLSectionName
                       toBehaviorNode:behaviorNode
                 usingMemberNodeClass:[AKMethodNode class]
                      blockForGetting:blockForGettingMemberNode(instanceMethodWithName)
                       blockForAdding:blockForAddingMemberNode(addInstanceMethod)];

    // Add member nodes specific to classes.
    if ([behaviorNode isClassNode])
    {
        // Add delegate method nodes.
        [self _addMembersFromMajorSection:AKDelegateMethodsHTMLSectionName
                           toBehaviorNode:behaviorNode
                     usingMemberNodeClass:[AKMethodNode class]
                          blockForGetting:blockForGettingMemberNode(delegateMethodWithName)
                           blockForAdding:blockForAddingMemberNode(addDelegateMethod)];

        [self _addMembersFromMajorSection:AKDelegateMethodsAlternateHTMLSectionName
                           toBehaviorNode:behaviorNode
                     usingMemberNodeClass:[AKMethodNode class]
                          blockForGetting:blockForGettingMemberNode(delegateMethodWithName)
                           blockForAdding:blockForAddingMemberNode(addDelegateMethod)];

        // Add method nodes for notifications.
        [self _addMembersFromMajorSection:AKNotificationsHTMLSectionName
                           toBehaviorNode:behaviorNode
                     usingMemberNodeClass:[AKNotificationNode class]
                          blockForGetting:blockForGettingMemberNode(notificationWithName)
                           blockForAdding:blockForAddingMemberNode(addNotification)];
    }
}

@end

