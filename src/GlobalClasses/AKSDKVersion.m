//
//  AKSDKVersion.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/10.
//  Copyright 2010 Andy Lee. All rights reserved.
//

#import "AKSDKVersion.h"


@implementation AKSDKVersion


#pragma mark -
#pragma mark Factory methods

+ (id)versionFromString:(NSString *)versionString
{
	id version = [[[self alloc] init] autorelease];
	NSArray *versionParts = [versionString componentsSeparatedByString:@"."];
	
	if ([versionParts count] > 0)
	{
		[version setMajorNumber:[[versionParts objectAtIndex:0] intValue]];
	}
	
	if ([versionParts count] > 1)
	{
		[version setMinorNumber:[[versionParts objectAtIndex:1] intValue]];
	}
	
	if ([versionParts count] > 2)
	{
		[version setPatchNumber:[[versionParts objectAtIndex:2] intValue]];
	}
	
	return version;
}


#pragma mark -
#pragma mark Getters and setters

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


#pragma mark -
#pragma mark NSObject methods

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
	
	return ((_majorNumber == [other majorNumber]) && (_minorNumber == [other minorNumber]) && (_patchNumber == [other patchNumber]));
}


#pragma mark -
#pragma mark Comparing versions

- (BOOL)coversVersion:(AKSDKVersion *)otherVersion
{
	if (_patchNumber > 0)
	{
		return (_patchNumber == [otherVersion patchNumber]);
	}
	else
	{
		return ((_majorNumber == [otherVersion majorNumber]) && (_minorNumber == [otherVersion minorNumber]));
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

@end
