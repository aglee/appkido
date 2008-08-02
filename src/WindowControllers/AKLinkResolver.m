/*
 * AKLinkResolver.m
 *
 * Created by Andy Lee on Sun Mar 07 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKLinkResolver.h"

#import <DIGSLog.h>

#import "AKFrameworkConstants.h"
#import "AKHTMLConstants.h"

#import "AKTextUtils.h"

#import "AKDatabase.h"
#import "AKFileSection.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKPropertyNode.h"
#import "AKMethodNode.h"
#import "AKNotificationNode.h"
#import "AKFunctionNode.h"
#import "AKGlobalsNode.h"
#import "AKCocoaFramework.h"

#import "AKDocLocator.h"

#import "AKSubtopic.h"
#import "AKClassTopic.h"
#import "AKProtocolTopic.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"
#import "AKOverviewDoc.h"

#import "AKAppController.h"
#import "AKFrameworkSetup.h"

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKLinkResolver (Private)

@end


@implementation AKLinkResolver

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)linkResolverWithDatabase:(AKDatabase *)database
{
    return [[[self alloc] initWithDatabase:database] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithDatabase:(AKDatabase *)database
{
    if ((self = [super init]))
    {
        _database = [database retain];
    }

    return self;
}

- (id)init
{
    DIGSLogNondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_database release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Resolving links
//-------------------------------------------------------------------------

- (AKBehaviorTopic *)_topicForBehavior:(AKBehaviorNode *)behaviorNode
{
    return
        [behaviorNode isClassNode]
        ? [AKClassTopic topicWithClassNode:(AKClassNode *)behaviorNode]
        : [AKProtocolTopic topicWithProtocolNode:(AKProtocolNode *)behaviorNode];
}

- (AKDocLocator *)_docLocatorForBehavior:(AKBehaviorNode *)behaviorNode
    inFramework:(NSString *)frameworkName
{
    NSString *docName = AKClassDescriptionAlternateHTMLSectionName;

    if (![frameworkName isEqualToString:[behaviorNode owningFramework]])
    {
        docName =
            [AKOverviewDoc
                qualifyDocName:docName
                withFrameworkName:frameworkName];
    }

    return
        [AKDocLocator
            withTopic:[self _topicForBehavior:behaviorNode]
            subtopicName:AKOverviewSubtopicName
            docName:docName];
}

- (AKDocLocator *)_docLocatorForProperty:(AKPropertyNode *)propertyNode
{
    return
        [AKDocLocator
            withTopic:[self _topicForBehavior:[propertyNode owningBehavior]]
            subtopicName:AKPropertiesSubtopicName
            docName:[propertyNode nodeName]];
}

- (AKDocLocator *)_docLocatorForMethod:(AKMethodNode *)methodNode
{
    AKBehaviorTopic *behaviorTopic =
        [self _topicForBehavior:[methodNode owningBehavior]];
    NSString *methodName = [methodNode nodeName];

    if ([methodNode isClassMethod])
    {
        DIGSLogDebug(@"AKLinkResolver -- _CLASS METHOD_ node [%@]", methodName);
        return
            [AKDocLocator
                withTopic:behaviorTopic
                subtopicName:AKClassMethodsSubtopicName
                docName:methodName];
    }
    else if ([methodNode isDelegateMethod])
    {
        DIGSLogDebug(@"AKLinkResolver -- _DELEGATE METHOD_ node [%@]", methodName);
        return
            [AKDocLocator
                withTopic:behaviorTopic
                subtopicName:AKDelegateMethodsSubtopicName
                docName:methodName];
    }
    else
    {
        DIGSLogDebug(@"AKLinkResolver -- _INSTANCE METHOD_ node [%@]", methodName);
        return
            [AKDocLocator
                withTopic:behaviorTopic
                subtopicName:AKInstanceMethodsSubtopicName
                docName:methodName];
    }
}

- (AKDocLocator *)_docLocatorForNotification:(AKNotificationNode *)notificationNode
{
    DIGSLogDebug(@"AKLinkResolver -- _NOTIFICATION_ node [%@]", [notificationNode nodeName]);
    return
        [AKDocLocator
            withTopic:[self _topicForBehavior:[notificationNode owningBehavior]]
            subtopicName:AKNotificationsSubtopicName
            docName:[notificationNode nodeName]];
}

- (AKDocLocator *)_docLocatorForFunction:(AKFunctionNode *)functionNode
{
    DIGSLogDebug(@"AKLinkResolver -- _FUNCTION_ node [%@]", [functionNode nodeName]);
    return nil;
}

- (AKDocLocator *)_docLocatorForGlobalsNode:(AKGlobalsNode *)globalsNode
{
    DIGSLogDebug(@"AKLinkResolver -- _GLOBALS_ node [%@]", [globalsNode nodeName]);
    return nil;
}

- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL
{
    NSURL *normalizedLinkURL = [[linkURL absoluteURL] standardizedURL];
    NSString *filePath = [normalizedLinkURL path];

    NSString *frameworkName = [_database frameworkForHTMLFile:filePath];

DIGSLogDebug(@"AKLinkResolver -- path = [%@], framework = [%@], anchor = [%@]",  // [agl] REMOVE
    filePath, frameworkName, [normalizedLinkURL fragment]);

    if (frameworkName == nil)
    {
        DIGSLogDebug(@"AKLinkResolver -- couldn't determine framework for file [%@]", filePath);
        return nil;
    }

    NSString *linkAnchor = [normalizedLinkURL fragment];
    NSString *nodeName = [[linkAnchor pathComponents] lastObject];
    id node = [_database nodeForTokenName:nodeName inHTMLFile:filePath];

    if (node == nil)
    {
        DIGSLogDebug(@"AKLinkResolver -- couldn't find node [%@] in file [%@]",
            nodeName, filePath);
        return nil;
    }

    if ([node isKindOfClass:[AKClassNode class]]
        || [node isKindOfClass:[AKProtocolNode class]])
    {
        return [self _docLocatorForBehavior:node inFramework:frameworkName];
    }
    else if ([node isKindOfClass:[AKPropertyNode class]])
    {
        return [self _docLocatorForProperty:node];
    }
    else if ([node isKindOfClass:[AKMethodNode class]])
    {
        return [self _docLocatorForMethod:node];
    }
    else if ([node isKindOfClass:[AKNotificationNode class]])
    {
        return [self _docLocatorForNotification:node];
    }
    else if ([node isKindOfClass:[AKFunctionNode class]])
    {
        return [self _docLocatorForFunction:node];
    }
    else if ([node isKindOfClass:[AKGlobalsNode class]])
    {
        return [self _docLocatorForGlobalsNode:node];
    }

    return nil;
//    return [self xxxdocLocatorForURL:linkURL];  // [agl] REMOVE

}



- (AKDocLocator *)xxxdocLocatorForURL:(NSURL *)linkURL  // [agl] REMOVE
{
    NSURL *normalizedLinkURL = [[linkURL absoluteURL] standardizedURL];
    NSString *filePath = [normalizedLinkURL path];
    NSString *frameworkName = [_database frameworkForHTMLFile:filePath];

DIGSLogDebug(@"AKLinkResolver -- path = [%@], framework = [%@], anchor = [%@]",  // [agl] REMOVE
    filePath, frameworkName, [normalizedLinkURL fragment]);

    if (frameworkName == nil)
    {
        DIGSLogDebug(@"AKLinkResolver -- couldn't determine framework for file [%@]", filePath);
        return nil;
    }

    NSString *linkAnchor = [normalizedLinkURL fragment];
    NSEnumerator *en = [[linkAnchor pathComponents] objectEnumerator];
    NSString *anchorComponent;

    while ((anchorComponent = [en nextObject]))
    {
        if ([anchorComponent isEqualToString:@"occ"])
        {
            AKBehaviorNode *behaviorNode = nil;
            AKBehaviorTopic *behaviorTopic = nil;

            NSString *tokenType = [en nextObject];

            if ([tokenType isEqualToString:@"cl"]
                || [tokenType isEqualToString:@"instp"]
                || [tokenType isEqualToString:@"clm"]
                || [tokenType isEqualToString:@"instm"])
            {
                NSString *className = [en nextObject];
                AKClassNode *classNode = [_database classWithName:className];

                if (classNode == nil)
                {
                    DIGSLogDebug(@"AKLinkResolver -- couldn't find class with name [%@]", className);
                    return nil;
                }

                behaviorNode = classNode;
                behaviorTopic = [AKClassTopic topicWithClassNode:classNode];
            }
            else if ([tokenType isEqualToString:@"intf"]
                || [tokenType isEqualToString:@"intfp"]
                || [tokenType isEqualToString:@"intfcm"]
                || [tokenType isEqualToString:@"intfm"])
            {
                NSString *protocolName = [en nextObject];
                AKProtocolNode *protocolNode = [_database protocolWithName:protocolName];

                if (protocolNode == nil)
                {
                    DIGSLogDebug(@"AKLinkResolver -- couldn't find protocol with name [%@]", protocolName);
                    return nil;
                }

                behaviorNode = protocolNode;
                behaviorTopic = [AKProtocolTopic topicWithProtocolNode:protocolNode];
            }

            // Does the link point to a class/protocol?
            if ([tokenType isEqualToString:@"cl"]
                || [tokenType isEqualToString:@"intf"])
            {
                NSString *docName = AKOverviewSubtopicName;

                if (![frameworkName isEqualToString:[behaviorNode owningFramework]])
                {
                    docName =
                        [AKOverviewDoc
                            qualifyDocName:docName
                            withFrameworkName:frameworkName];
                }

                return
                    [AKDocLocator
                        withTopic:behaviorTopic
                        subtopicName:AKOverviewSubtopicName
                        docName:docName];
            }

            // Does the link point to a property?
            if ([tokenType isEqualToString:@"instp"]
                || [tokenType isEqualToString:@"intfp"])
            {
                NSString *propertyName = [en nextObject];
                return
                    [AKDocLocator
                        withTopic:behaviorTopic
                        subtopicName:AKPropertiesSubtopicName
                        docName:propertyName];
            }

            // Does the link point to a class method?
            if ([tokenType isEqualToString:@"clm"]
                || [tokenType isEqualToString:@"intfcm"])
            {
                NSString *methodName = [en nextObject];
                return
                    [AKDocLocator
                        withTopic:behaviorTopic
                        subtopicName:AKClassMethodsSubtopicName
                        docName:methodName];
            }

            // Does the link point to an instance method?
            if ([tokenType isEqualToString:@"instm"]
                || [tokenType isEqualToString:@"intfm"])
            {
                NSString *methodName = [en nextObject];
                return
                    [AKDocLocator
                        withTopic:behaviorTopic
                        subtopicName:AKInstanceMethodsSubtopicName
                        docName:methodName];
            }

            // Last ditch: see if the link points to a global.
            NSString *possibleNameOfGlobal = [en nextObject];
            return
                [self
                    _docLocatorForGlobal:possibleNameOfGlobal
                    inFramework:frameworkName];
        }
        else if ([anchorComponent isEqualToString:@"c"])
        {
            NSString *tokenType = [en nextObject];

            // Does the link point to a function/macro?
            if ([tokenType isEqualToString:@"func"]
                || [tokenType isEqualToString:@"macro"])
            {
                NSString *functionName = [en nextObject];

                AKGroupNode *functionsGroupNode =
                    [_database
                        functionsGroupContainingFunction:functionName
                        inFramework:frameworkName];

                if (functionsGroupNode == nil)
                {
                    DIGSLogDebug(@"AKLinkResolver -- couldn't find function named [%@] in framework [%@]",
                        functionName, frameworkName);
                    return nil;
                }

                return
                    [AKDocLocator
                        withTopic:[AKFunctionsTopic topicWithFrameworkName:frameworkName]
                        subtopicName:[functionsGroupNode nodeName]
                        docName:functionName];
            }

            // Last ditch: see if the link points to a global.
            NSString *possibleNameOfGlobal = [en nextObject];
            return
                [self
                    _docLocatorForGlobal:possibleNameOfGlobal
                    inFramework:frameworkName];
        }
    }

    // If we got this far, we couldn't figure out what we're linking to.
    return nil;
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKLinkResolver (Private)

@end
