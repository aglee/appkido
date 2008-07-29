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

- (NSString *)_overviewDocNameForBehavior:(AKBehaviorNode *)behaviorNode
    inFramework:(NSString *)frameworkName
{
    if ([frameworkName isEqualToString:[behaviorNode owningFramework]])
    {
        return AKClassDescriptionAlternateHTMLSectionName;
    }
    else
    {
        return
            [AKOverviewDoc
                qualifyDocName:AKClassDescriptionAlternateHTMLSectionName
                withFrameworkName:frameworkName];
    }
}

- (AKDocLocator *)_docLocatorForClassNamed:(NSString *)className
    inFramework:(NSString *)frameworkName
{
    DIGSLogDebug(@"AKLinkResolver -- class [%@] in framework [%@]",
        className, frameworkName);

    AKClassNode *classNode = [_database classWithName:className];

    if (classNode == nil)
    {
        DIGSLogDebug(@"AKLinkResolver -- couldn't find class with name [%@]", className);
        return nil;
    }

    NSString *docName =
        [self
            _overviewDocNameForBehavior:classNode
            inFramework:frameworkName];

    return
        [AKDocLocator
            withTopic:[AKClassTopic withClassNode:classNode]
            subtopicName:AKOverviewSubtopicName
            docName:docName];
}

- (AKDocLocator *)_docLocatorForProtocolNamed:(NSString *)protocolName
    inFramework:(NSString *)frameworkName
{
    DIGSLogDebug(@"AKLinkResolver -- protocol [%@] in framework [%@]",
        protocolName, frameworkName);

    AKProtocolNode *protocolNode = [_database protocolWithName:protocolName];

    if (protocolNode == nil)
    {
        DIGSLogDebug(@"AKLinkResolver -- couldn't find protocol with name [%@]", protocolName);
        return nil;
    }

    NSString *docName =
        [self
            _overviewDocNameForBehavior:protocolNode
            inFramework:frameworkName];

    return
        [AKDocLocator
            withTopic:[AKProtocolTopic withProtocolNode:protocolNode]
            subtopicName:AKOverviewSubtopicName
            docName:docName];
}

- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL
{
    NSURL *normalizedLinkURL = [[linkURL absoluteURL] standardizedURL];
    NSString *filePath = [normalizedLinkURL path];
    NSString *fwName = [_database frameworkForHTMLFile:filePath];

DIGSLogDebug(@"AKLinkResolver -- path = [%@], framework = [%@], anchor = [%@]",  // [agl] REMOVE
    filePath, fwName, [normalizedLinkURL fragment]);

    if (fwName == nil)
    {
        DIGSLogDebug(@"couldn't determine framework for file [%@]", filePath);
        return nil;
    }

    NSString *linkAnchor = [normalizedLinkURL fragment];
    NSEnumerator *en = [[linkAnchor pathComponents] objectEnumerator];
    NSString *anchorComponent;

    while ((anchorComponent = [en nextObject]))
    {
        if ([anchorComponent isEqualToString:@"occ"])
        {
            NSString *tokenType = [en nextObject];

            if ([tokenType isEqualToString:@"cl"])
            {
                return
                    [self
                        _docLocatorForClassNamed:[en nextObject]
                        inFramework:fwName];
            }
            else if ([tokenType isEqualToString:@"intf"])
            {
                return
                    [self
                        _docLocatorForProtocolNamed:[en nextObject]
                        inFramework:fwName];
            }

            break;
        }
        else if ([anchorComponent isEqualToString:@"c"])
        {
/*
            NSString *tokenType = [en nextObject];
            NSString *tokenName = [en nextObject];

            behaviorNode = nil;
            rootSection = [_database rootSectionForHTMLFile:filePath];
            docTopic = [AKFunctionsTopic withFrameworkName:fwName];


            behaviorNode = nil;
            rootSection = [_database rootSectionForHTMLFile:filePath];
            docTopic = [AKGlobalsTopic withFrameworkName:fwName];


            return nil;
*/
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
