/*
 * DIGSPrefUtils.m
 *
 * Created by Andy Lee on 1/26/08.
 * Copyright 2008 Andy Lee. All rights reserved.
 */

#import "DIGSPrefUtils.h"

@interface DIGSPrefUtils (Private)
+ (id)_valueWhoseClassIs:(Class)cl forPref:(NSString *)prefName;
@end


@implementation DIGSPrefUtils


#pragma mark -
#pragma mark Low-level getters and setters

+ (BOOL)boolValueForPref:(NSString *)prefName
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:prefName];
}

+ (void)setBoolValue:(BOOL)prefValue forPref:(NSString *)prefName
{
    [[NSUserDefaults standardUserDefaults]
        setBool:prefValue forKey:prefName];
}

+ (int)intValueForPref:(NSString *)prefName
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:prefName];
}

+ (void)setIntValue:(int)prefValue forPref:(NSString *)prefName
{
    [[NSUserDefaults standardUserDefaults]
        setInteger:prefValue forKey:prefName];
}

+ (NSString *)stringValueForPref:(NSString *)prefName
{
    return [self _valueWhoseClassIs:[NSString class] forPref:prefName];
}

+ (void)setStringValue:(NSString *)prefValue forPref:(NSString *)prefName
{
    [[NSUserDefaults standardUserDefaults]
        setObject:prefValue forKey:prefName];
}

+ (NSArray *)arrayValueForPref:(NSString *)prefName
{
    return [self _valueWhoseClassIs:[NSArray class] forPref:prefName];
}

+ (void)setArrayValue:(NSArray *)prefValue forPref:(NSString *)prefName
{
    [[NSUserDefaults standardUserDefaults]
        setObject:prefValue forKey:prefName];
}

+ (NSDictionary *)dictionaryValueForPref:(NSString *)prefName
{
    return [self _valueWhoseClassIs:[NSDictionary class] forPref:prefName];
}

+ (void)setDictionaryValue:(NSDictionary *)prefValue
    forPref:(NSString *)prefName
{
    [[NSUserDefaults standardUserDefaults]
        setObject:prefValue forKey:prefName];
}

@end


@implementation DIGSPrefUtils (Private)

+ (id)_valueWhoseClassIs:(Class)cl forPref:(NSString *)prefName
{
    id prefValue =
        [[NSUserDefaults standardUserDefaults] objectForKey:prefName];

    if ([prefValue isKindOfClass:cl])
    {
        return prefValue;
    }
    else
    {
        return nil;
    }
}

@end
