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
 * Tries to derive a doc locator from the given URL. If we succeed, we can
 * follow the link within AppKiDo. Otherwise, we have to open the link in the
 * user's browser.
 */
- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL;

@end
