//
//  AKWindowController+Links.m
//  AppKiDo
//
//  Created by Andy Lee on 6/9/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKWindowController.h"
#import "AKDocLocator.h"
#import "AKDocListViewController.h"
#import "AKDocViewController.h"
#import "AKSearchQuery.h"
#import "AKToken.h"
#import "AKTopic.h"
#import "DIGSLog.h"

@implementation AKWindowController (Links)

- (BOOL)followLinkURL:(NSURL *)linkURL
{
	// Interpret the link URL as relative to the current doc URL.
	NSURL *currentDocFileURL = [NSURL URLWithString:_docViewController.webView.mainFrameURL];
	NSURL *destinationURL = [NSURL URLWithString:linkURL.relativeString relativeToURL:currentDocFileURL];

	// If we have a file: URL, try to derive a doc locator from it.
	AKDocLocator *destinationDocLocator = [self _docLocatorForURL:destinationURL];

	// If we derived a doc locator, go to it. Otherwise, try opening the file in
	// the user's browser.
	if (destinationDocLocator) {
		[self selectDocWithDocLocator:destinationDocLocator];
		[_docListController focusOnDocListTable];
		[self showWindow:nil];
		return YES;
	} else if ([[NSWorkspace sharedWorkspace] openURL:destinationURL]) {
		DIGSLogDebug(@"NSWorkspace opened URL [%@]", destinationURL);
		return YES;
	} else {
		DIGSLogWarning(@"NSWorkspace couldn't open URL [%@]", destinationURL);
		return NO;
	}
}

#pragma mark - Private methods

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
// Uses AKSearchQuery to do an initial search, then searches the search results
// for a match.
//TODO: Is there a more efficient/reliable way?  How about parsing the link's path for clues?
//TODO: Document what anchors look like, and why comparing link anchor with token anchor isn't enough.  See the comment on the matchesLinkURL: method.
- (AKDocLocator *)_docLocatorForURL:(NSURL *)linkURL
{
	if (!linkURL.fileURL) {
		return nil;
	}

	NSString *linkAnchor = linkURL.fragment;
	NSArray *searchResults = [self _searchForLinkAnchorComponent:linkAnchor.lastPathComponent];

	// Search the search results for a token whose anchor matches the URL of the
	// link we are trying to traverse.
	for (AKDocLocator *docLocator in searchResults) {
		// If the doc is a token, see if it matches.
		if ([docLocator.docToDisplay isKindOfClass:[AKToken class]]) {
			if ([(AKToken *)docLocator.docToDisplay matchesLinkURL:linkURL]) {
				return docLocator;
			}
		}

		// If the topic has a token, see if it matches.
		if ([docLocator.topicToDisplay.topicToken matchesLinkURL:linkURL]) {
			return docLocator;
		}
	}

	// If we got this far, there's no match, or at least I don't know how to
	// figure out what it is.
	return nil;
}

// Not to be confused with user-facing search done in the quicklist pane.  We
// use search here internally to help traverse links the user clicks on.
- (NSArray *)_searchForLinkAnchorComponent:(NSString *)searchString
{
	NSArray *searchResults;

	// Try searching for the string verbatim.
	AKSearchQuery *searchQuery = [[AKSearchQuery alloc] initWithDatabase:self.database];
	[searchQuery includeEverythingInSearch];
	searchQuery.ignoresCase = YES;
	searchQuery.searchComparison = AKSearchForExactMatch;
	searchResults = [searchQuery doSearchForString:searchString];

	// If we found nothing, try again but replace underscores with spaces and
	// try a prefix search.
	//TODO: What was the reasoning behind this logic again?  I *think* it's from the ability in "old AppKiDo" to search group names.  Might still make sense when I add the ability to search nodes as well as tokens.
	if (searchResults.count == 0) {
		searchQuery.searchComparison = AKSearchForPrefix;
		searchString = [searchString stringByReplacingOccurrencesOfString:@"_" withString:@" "];
		searchResults = [searchQuery doSearchForString:searchString];
	}

	return searchResults;
}

@end
