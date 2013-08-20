/*
 * AKLinkResolver.m
 *
 * Created by Andy Lee on Sun Mar 07 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKLinkResolver.h"

#import "DIGSLog.h"

#import "AKDatabase.h"
#import "AKDatabaseNode.h"
#import "AKDoc.h"
#import "AKDocLocator.h"
#import "AKFileSection.h"
#import "AKSearchQuery.h"
#import "AKTopic.h"

@implementation AKLinkResolver

@synthesize database = _database;

#pragma mark -
#pragma mark Factory methods

+ (id)linkResolverWithDatabase:(AKDatabase *)database
{
    return [[[self alloc] initWithDatabase:database] autorelease];
}

#pragma mark -
#pragma mark Init/awake/dealloc

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
    DIGSLogError_NondesignatedInitializer();
    return nil;
}

- (void)dealloc
{
    [_database release];

    [super dealloc];
}

#pragma mark -
#pragma mark Resolving links

// In the Apple dev docs, if a link points to the doc for an API symbol, that
// symbol is the last path component of the link's anchor. For example, if the
// anchor is "//apple_ref/doc/c_ref/NSZone" we assume it refers to NSZone.
//
// Another possibility is that the link points to a document that is not about
// one single API symbol. In this case the link's anchor ends not with a symbol,
// but with the title of the doc, with underscores replacing spaces. Example: in
// the NSPointerFunctionsOptions doc, there's a link to "Memory and Personality
// Options"; the link's anchor is
// //apple_ref/doc/constant_group/Memory_and_Personality_Options. Another
// example: in the doc for NSStringEncoding, there's a link to
// "String Encodings"; the link's anchor is
// //apple_ref/doc/constant_group/String_Encodings.
//
// [agl] The implementation uses AKSearchQuery to search for the API symbol.
// Right now it searches the whole database and then searches the search results
// for a node whose file path matches the link's path. We can probably narrow
// down the search query by noticing for example that "c_ref" means NSZone is a
// class. Better yet, we could make AKSearchQuery more efficient in general.
- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL
{
    NSURL *normalizedLinkURL = [[linkURL absoluteURL] standardizedURL];
    NSString *filePath = [normalizedLinkURL path];
    NSString *linkAnchor = [normalizedLinkURL fragment];
    NSString *tokenNameOrDocTitle = [linkAnchor lastPathComponent];

    AKSearchQuery *searchQuery = [[[AKSearchQuery alloc] initWithDatabase:_database] autorelease];
    
    [searchQuery setSearchString:tokenNameOrDocTitle];
    [searchQuery includeEverythingInSearch];
    [searchQuery setIgnoresCase:YES];
    [searchQuery setSearchComparison:AKSearchForExactMatch];

    if ([[searchQuery queryResults] count] == 0)
    {
        tokenNameOrDocTitle = [tokenNameOrDocTitle stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        [searchQuery setSearchComparison:AKSearchForPrefix];
        [searchQuery setSearchString:tokenNameOrDocTitle];
    }

    for (AKDocLocator *docLocator in [searchQuery queryResults])
    {
        AKFileSection *docSection = [[docLocator docToDisplay] fileSection];

        if (docSection == nil)
        {
            docSection = [[[docLocator topicToDisplay] topicNode] nodeDocumentation];
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
