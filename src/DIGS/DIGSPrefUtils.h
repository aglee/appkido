/*
 * DIGSPrefUtils.h
 *
 * Created by Andy Lee on 1/26/08.
 * Copyright 2008 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * Convenience methods for getting and setting user preferences. Implemented as
 * wrappers around NSUserDefaults methods.
 */
#import <Cocoa/Cocoa.h>

@interface DIGSPrefUtils : NSObject

+ (BOOL)boolValueForPref:(NSString *)prefName;
+ (void)setBoolValue:(BOOL)value forPref:(NSString *)prefName;

+ (NSInteger)intValueForPref:(NSString *)prefName;
+ (void)setIntValue:(NSInteger)value forPref:(NSString *)prefName;

+ (NSString *)stringValueForPref:(NSString *)prefName;
+ (void)setStringValue:(NSString *)value forPref:(NSString *)prefName;

+ (NSArray *)arrayValueForPref:(NSString *)prefName;
+ (void)setArrayValue:(NSArray *)value forPref:(NSString *)prefName;

+ (NSDictionary *)dictionaryValueForPref:(NSString *)prefName;
+ (void)setDictionaryValue:(NSDictionary *)value forPref:(NSString *)prefName;

@end
