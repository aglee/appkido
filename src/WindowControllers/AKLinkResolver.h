/*
 * AKLinkResolver.h
 *
 * Created by Andy Lee on Sun Mar 07 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKDatabase;
@class AKDocLocator;

/*!
 * Used for traversing hyperlinks in the documentation.
 */
@interface AKLinkResolver : NSObject
{
@private
    AKDatabase *_database;
}

@property (nonatomic, readonly, strong) AKDatabase *database;

#pragma mark -
#pragma mark Factory methods

+ (id)linkResolverWithDatabase:(AKDatabase *)database;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithDatabase:(AKDatabase *)database;

#pragma mark -
#pragma mark Resolving links

/*!
 * Tries to derive a doc locator from the given URL. Uses the fact that in the
 * Apple dev docs, if a link refers to the docs for an API symbol, that symbol
 * is the last path component of the link's anchor. For example, if the anchor
 * is "//apple_ref/doc/c_ref/NSZone" we can assume it refers to NSZone.
 *
 * [agl] The implementation uses AKSearchQuery to search for the API symbol.
 * Right now it searches the whole database and then searches the search results
 * for a node whose file path matches the link's path. We can probably narrow
 * down the search query by noticing for example that "c_ref" means NSZone is a
 * class.
 */
- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL;

@end
