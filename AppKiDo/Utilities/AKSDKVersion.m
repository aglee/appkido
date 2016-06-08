//
//  AKSDKVersion.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/10.
//  Copyright 2010 Andy Lee. All rights reserved.
//

#import "AKSDKVersion.h"


// Moved here from the now defunct AKDevTools.m.
// Used for sorting SDK version strings.
//TODO: Why didn't I use AKSDKVersion to do the comparing?
static NSComparisonResult _versionSortFunction(NSString * leftVersionString, NSString * rightVersionString, void *ignoredContext)
{
	NSArray *leftComponents = [leftVersionString componentsSeparatedByString:@"."];
	NSArray *rightComponents = [rightVersionString componentsSeparatedByString:@"."];
	unsigned int i;

	for (i = 0; i < leftComponents.count; i++) {
		if (i >= rightComponents.count) {
			return NSOrderedDescending;  // left has more components and is therefore greater than right
		}

		int leftNumber = [leftComponents[i] intValue];
		int rightNumber = [rightComponents[i] intValue];

		if (leftNumber < rightNumber) {
			return NSOrderedAscending;
		} else if (leftNumber > rightNumber) {
			return NSOrderedDescending;
		}
	}

	// If we got this far, rightComponents has leftComponents as a prefix.
	if (leftComponents.count < rightComponents.count) {
		return NSOrderedAscending;  // left has fewer components and is therefore less than right
	} else {
		return NSOrderedSame;  // all left components equal all right components
	}
}



@implementation AKSDKVersion

#pragma mark - Factory methods

+ (instancetype)versionFromString:(NSString *)versionString
{
	id version = [[self alloc] init];
	NSArray *versionParts = [versionString componentsSeparatedByString:@"."];
	
	if (versionParts.count > 0)
	{
		[version setMajorNumber:[versionParts[0] intValue]];
	}
	
	if (versionParts.count > 1)
	{
		[version setMinorNumber:[versionParts[1] intValue]];
	}
	
	if (versionParts.count > 2)
	{
		[version setPatchNumber:[versionParts[2] intValue]];
	}
	
	return version;
}

#pragma mark - Getters and setters

- (int)majorNumber
{
	return _majorNumber;
}

- (void)setMajorNumber:(int)n
{
	_majorNumber = n;
}

- (int)minorNumber
{
	return _minorNumber;
}

- (void)setMinorNumber:(int)n
{
	_minorNumber = n;
}

- (int)patchNumber
{
	return _patchNumber;
}

- (void)setPatchNumber:(int)n
{
	_patchNumber = n;
}

#pragma mark - Comparing versions

- (BOOL)coversVersion:(AKSDKVersion *)otherVersion
{
	if (_patchNumber > 0)
	{
		return (_patchNumber == [otherVersion patchNumber]);
	}
	else
	{
		return ((_majorNumber == [otherVersion majorNumber])
                && (_minorNumber == [otherVersion minorNumber]));
	}
}

- (BOOL)isGreaterThanVersion:(AKSDKVersion *)otherVersion
{
	if (_majorNumber > [otherVersion majorNumber])
	{
		return YES;
	}
	else if (_majorNumber == [otherVersion majorNumber])
	{
		if (_minorNumber > [otherVersion minorNumber])
		{
			return YES;
		}
		else if (_minorNumber == [otherVersion minorNumber])
		{
			return (_patchNumber > [otherVersion patchNumber]);
		}
	}
	
	// If we got this far, we've exhausted all the ways we could be greater than otherVersion.
	return NO;
}

#pragma mark - NSObject methods

- (NSString *)description
{
	if (_patchNumber == 0)
	{
		return [NSString stringWithFormat:@"%d.%d", _majorNumber, _minorNumber];
	}
	else
	{
		return [NSString stringWithFormat:@"%d.%d.%d", _majorNumber, _minorNumber, _patchNumber];
	}
}

- (BOOL)isEqual:(id)other
{
	if (![other isKindOfClass:[AKSDKVersion class]])
	{
		return NO;
	}

	return ((_majorNumber == [other majorNumber])
            && (_minorNumber == [other minorNumber])
            && (_patchNumber == [other patchNumber]));
}

@end
