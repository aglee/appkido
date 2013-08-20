//
//  AKSDKVersion.h
//  AppKiDo
//
//  Created by Andy Lee on 5/8/10.
//  Copyright 2010 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AKSDKVersion : NSObject
{
@private
	int _majorNumber;
	int _minorNumber;
	int _patchNumber;
}

#pragma mark -
#pragma mark Factory methods

+ (id)versionFromString:(NSString *)versionString;

#pragma mark -
#pragma mark Getters and setters

- (int)majorNumber;
- (void)setMajorNumber:(int)n;

- (int)minorNumber;
- (void)setMinorNumber:(int)n;

- (int)patchNumber;
- (void)setPatchNumber:(int)n;

#pragma mark -
#pragma mark Comparing versions

- (BOOL)coversVersion:(AKSDKVersion *)otherVersion;
- (BOOL)isGreaterThanVersion:(AKSDKVersion *)otherVersion;

@end
