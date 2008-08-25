/*
 * AKLinkResolver.m
 *
 * Created by Andy Lee on Sun Mar 07 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKLinkResolver.h"

#import "DIGSLog.h"

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

#import "AKDocLocator.h"
#import "AKSearchQuery.h"

#import "AKSubtopic.h"
#import "AKClassTopic.h"
#import "AKProtocolTopic.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"
#import "AKOverviewDoc.h"

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

- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL
{
    NSURL *normalizedLinkURL = [[linkURL absoluteURL] standardizedURL];
    NSString *filePath = [normalizedLinkURL path];
    NSString *linkAnchor = [normalizedLinkURL fragment];
    NSString *tokenName = [[linkAnchor pathComponents] lastObject];

    AKSearchQuery *searchQuery =
        [[[AKSearchQuery alloc] initWithDatabase:_database] autorelease];
    [searchQuery setSearchString:tokenName];
    [searchQuery setIncludesEverything];
    [searchQuery setIgnoresCase:YES];
    [searchQuery setSearchComparison:AKSearchForExactMatch];
    NSEnumerator *searchResultsEnum =
        [[searchQuery queryResults] objectEnumerator];
    AKDocLocator *docLocator;

    while ((docLocator = [searchResultsEnum nextObject]))
    {
        AKFileSection *docSection = [[docLocator docToDisplay] fileSection];

        if (docSection == nil)
        {
            docSection =
                [[[docLocator topicToDisplay] topicNode] nodeDocumentation];
        }

        if ([[docSection filePath] isEqualToString:filePath])
        {
            return docLocator;
        }
    }

    // If we got this far, there was no match.
    return nil;
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKLinkResolver (Private)

@end
