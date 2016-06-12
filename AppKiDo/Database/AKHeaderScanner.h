//
//  AKHeaderScanner.h
//  AppKiDo
//
//  Created by Andy Lee on 6/2/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define AKHeaderScannerClassNameKey @"ClassName"
#define AKHeaderScannerSuperclassNameKey @"SuperclassName"
#define AKHeaderScannerFrameworkNameKey @"FrameworkName"
/*! If HeaderPath begins with a "/", it is an absolute path.  Otherwise, it is relative to sdkBasePath. */
#define AKHeaderScannerHeaderPathNameKey @"HeaderPath"

@class AKInstalledSDK;

/*!
 * Scans header files looking for declarations of non-root Objective-C classes,
 * where the superclass is specified.
 */
@interface AKHeaderScanner : NSObject

#pragma mark - Init/awake/dealloc

- (instancetype)initWithInstalledSDK:(AKInstalledSDK *)installedSDK NS_DESIGNATED_INITIALIZER;

#pragma mark - Scanning header files

/*! Returns an array of dictionaries.  Dictionary keys are listed above. */
- (NSArray *)scanHeadersForClassDeclarations;

@end
