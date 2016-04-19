//
//  AKAppVersion.m
//  AppKiDo
//
//  Created by Andy Lee on 7/13/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import "AKAppVersion.h"

NSString *AKHomePageURL = @"http://appkido.com/";

@implementation AKAppVersion

@synthesize major = _major;
@synthesize minor = _minor;
@synthesize patch = _patch;
@synthesize sneakypeek = _sneakypeek;

+ (AKAppVersion *)appVersion
{
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    return [self appVersionFromString:versionString];
}

+ (AKAppVersion *)appVersionFromString:(NSString *)versionString
{
    NSArray *parts = nil;
    
    // Parse out the major version number.
    parts = [versionString componentsSeparatedByString:@"."];
    
    if ([parts count] != 2)
    {
        DIGSLogWarning(@"error parsing major/minor version numbers");
        return nil;
    }
    
    NSString *majorNumber = [parts objectAtIndex:0];
    NSString *minorNumber = [parts objectAtIndex:1];
    
    // Parse out the sneakypeek number if it's there.
    parts = [minorNumber componentsSeparatedByString:@"sp"];
    
    if ([parts count] > 2)
    {
        DIGSLogWarning(@"error parsing sneakypeek version number");
        return nil;
    }
    
    NSString *sneakypeekNumber = @"";
    
    if ([parts count] == 2)
    {
        minorNumber = [parts objectAtIndex:0];
        sneakypeekNumber = [parts objectAtIndex:1];
    }
    
    // Parse out the patch number if it's there.
    if (([minorNumber length] < 2) || ([minorNumber length] > 3))
    {
        DIGSLogWarning(@"error parsing minor/patch version numbers");
        return nil;
    }
    
    NSString *patchNumber = @"";
    
    if ([minorNumber length] == 3)
    {
        patchNumber = [minorNumber substringFromIndex:2];
        minorNumber = [minorNumber substringToIndex:2];
    }    
    
    // Construct and return an instance with the parts we have.
    AKAppVersion *appVersion = [[AKAppVersion alloc] init];
    
    [appVersion setMajor:majorNumber];
    [appVersion setMinor:minorNumber];
    [appVersion setSneakypeek:sneakypeekNumber];
    [appVersion setPatch:patchNumber];
    
    return appVersion;
}

- (BOOL)isNewerThanVersion:(AKAppVersion *)rhs
{
    NSComparisonResult comparison;

    // Compare the major version numbers.
    comparison = [self _compareValue:_major withValue:[rhs major] nilIsGreatest:NO];

    if (comparison == NSOrderedDescending)
    {
        return YES;
    }
    else if (comparison == NSOrderedAscending)
    {
        return NO;
    }

    // Compare the minor version numbers.
    comparison = [self _compareValue:_minor withValue:[rhs minor] nilIsGreatest:NO];

    if (comparison == NSOrderedDescending)
    {
        return YES;
    }
    else if (comparison == NSOrderedAscending)
    {
        return NO;
    }

    // Compare the patch version numbers, if they are present.
    comparison = [self _compareValue:_patch withValue:[rhs patch] nilIsGreatest:NO];

    if (comparison == NSOrderedDescending)
    {
        return YES;
    }
    else if (comparison == NSOrderedAscending)
    {
        return NO;
    }

    // Compare the sneakypeek version numbers, if they are present.
    comparison = [self _compareValue:_sneakypeek withValue:[rhs sneakypeek] nilIsGreatest:YES];

    if (comparison == NSOrderedDescending)
    {
        return YES;
    }
    else if (comparison == NSOrderedAscending)
    {
        return NO;
    }

    // If we got this far, all components matched.
    return NO;
}

- (NSString *)displayString
{
    // Concatenate the major and minor version numbers.
    NSMutableString *versionString = [NSMutableString stringWithFormat:@"%@.%@", _major, _minor];
    
    // See if there is a patch number.
    if ([_patch length])
    {
        [versionString appendString:_patch];
    }
    
    // See if there is a sneakypeek number.
    if ([_sneakypeek length])
    {
        [versionString appendFormat:@"sp%@", _sneakypeek];
    }
    
    // Return the result.
    return versionString;
}

#pragma mark -
#pragma mark Private methods

// If nilIsGreatest, then nil is "greater than" anything except itself.
// Otherwise, nil is "less than" anything except itself.
- (NSComparisonResult)_compareValue:(NSString *)lhs
                          withValue:rhs
                      nilIsGreatest:(BOOL)nilIsGreatest
{
    if ([@"" isEqualToString:lhs])
    {
        lhs = nil;
    }

    if ([@"" isEqualToString:rhs])
    {
        rhs = nil;
    }

    // Handle cases where values are identical, possibly by being nil.
    if (lhs == rhs)
    {
        return NSOrderedSame;
    }

    // If we got this far, we have at least one non-nil value.
    // Rule out the remaining nil cases.
    if (lhs == nil)
    {
        return nilIsGreatest ? NSOrderedDescending : NSOrderedAscending;
    }

    if (rhs == nil)
    {
        return nilIsGreatest ? NSOrderedAscending : NSOrderedDescending;
    }

    // If we got this far, we have two different non-nil values.
    return [lhs compare:rhs];
}

@end
