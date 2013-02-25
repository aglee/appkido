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
 * First steps toward more reliable resolving of hyperlinks, i.e., figuring
 * out what database node a given hyperlink points to.  I think this should
 * get simpler when (a) I drop support for pre-3.0 Xcode, and (b) I
 * overhaul the low-level parsing.
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

- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL;

@end
