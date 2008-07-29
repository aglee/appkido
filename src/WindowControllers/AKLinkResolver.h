/*
 * AKLinkResolver.h
 *
 * Created by Andy Lee on Sun Mar 07 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKDatabase;
@class AKDocLocator;

@interface AKLinkResolver : NSObject
{
    AKDatabase *_database;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)linkResolverWithDatabase:(AKDatabase *)database;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithDatabase:(AKDatabase *)database;

//-------------------------------------------------------------------------
// Resolving links
//-------------------------------------------------------------------------

- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL;

@end
