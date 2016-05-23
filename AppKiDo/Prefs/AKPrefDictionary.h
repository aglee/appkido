//
//  AKPrefDictionary.h
//  AppKiDo
//
//  Created by Andy Lee on 3/6/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AKPrefDictionary <NSObject>

@required

/*!
 * Returns an instance that has been initialized with the contents of prefDict,
 * which should be a plist, presumably gotten from NSUserDefaults.
 */
+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict;

/*!
 * Returns a plist dictionary suitable for use by NSUserDefaults. Uses the same
 * dictionary structure as +fromPrefDictionary.
 */
@property (readonly, copy) NSDictionary *asPrefDictionary;

@end
