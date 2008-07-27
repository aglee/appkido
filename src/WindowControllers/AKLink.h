/*
 * AKLink.h
 *
 * Created by Andy Lee on Sun Mar 07 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKDocLocator;

@interface AKLink : NSObject
{
}

//-------------------------------------------------------------------------
// Type conversion
//-------------------------------------------------------------------------

+ (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL;

@end
