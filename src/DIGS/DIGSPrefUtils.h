/*
 * DIGSPrefUtils.h
 *
 * Created by Andy Lee on 1/26/08.
 * Copyright 2008 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "AKPrefConstants.h"

/*!
 * @class       AKPrefUtils
 * @discussion  Utility methods for getting and setting user preferences.
 *              These are mostly wrappers around NSUserDefaults methods.
 */
#import <Cocoa/Cocoa.h>

@interface DIGSPrefUtils : NSObject
{
}


#pragma mark -
#pragma mark Low-level getters and setters

+ (BOOL)boolValueForPref:(NSString *)prefName;
+ (void)setBoolValue:(BOOL)value forPref:(NSString *)prefName;

+ (int)intValueForPref:(NSString *)prefName;
+ (void)setIntValue:(int)value forPref:(NSString *)prefName;

+ (NSString *)stringValueForPref:(NSString *)prefName;
+ (void)setStringValue:(NSString *)value forPref:(NSString *)prefName;

+ (NSArray *)arrayValueForPref:(NSString *)prefName;
+ (void)setArrayValue:(NSArray *)value forPref:(NSString *)prefName;

+ (NSDictionary *)dictionaryValueForPref:(NSString *)prefName;
+ (void)setDictionaryValue:(NSDictionary *)value
    forPref:(NSString *)prefName;

@end
