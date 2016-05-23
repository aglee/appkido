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

#pragma mark - Factory methods

+ (instancetype)versionFromString:(NSString *)versionString;

#pragma mark - Getters and setters

@property (NS_NONATOMIC_IOSONLY) int majorNumber;

@property (NS_NONATOMIC_IOSONLY) int minorNumber;

@property (NS_NONATOMIC_IOSONLY) int patchNumber;

#pragma mark - Comparing versions

- (BOOL)coversVersion:(AKSDKVersion *)otherVersion;
- (BOOL)isGreaterThanVersion:(AKSDKVersion *)otherVersion;

@end
