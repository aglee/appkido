//
//  AKAppVersion.h
//  AppKiDo
//
//  Created by Andy Lee on 7/13/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>


/*! URL of the downloads page for AppKiDo. */
extern NSString *AKHomePageURL;


/*!
 * The required format of a version string is X.YY{P}{spZ} where:
 *  X  (possibly multidigit)            is the "major version number"
 *  YY (exactly two digits)             is the "minor version number"
 *  P  (exactly one digit if present)   is the "patch number"
 *  Z  (possibly multidigit if present) is the "sneakypeak number"
 *
 * Examples:
 *  0.98
 *  0.981
 *  12.34sp3
 *  12.345sp3
 */
@interface AKAppVersion : NSObject
{
@private
    NSString *_major;
    NSString *_minor;
    NSString *_patch;
    NSString *_sneakypeek;
}

@property (strong) NSString *major;
@property (strong) NSString *minor;
@property (strong) NSString *patch;
@property (strong) NSString *sneakypeek;

+ (AKAppVersion *)appVersion;

+ (AKAppVersion *)appVersionFromString:(NSString *)versionString;

- (BOOL)isNewerThanVersion:(AKAppVersion *)rhs;

- (NSString *)displayString;

@end
