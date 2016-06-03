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

/*!
 * Scans header files looking for declarations of non-root Objective-C classes,
 * where the superclass is specified.
 */
@interface AKHeaderScanner : NSObject

- (instancetype)initWithSDKBasePath:(NSString *)sdkBasePath NS_DESIGNATED_INITIALIZER;

/*! Returns an array of dictionaries.  Dictionary keys are listed above. */
- (NSArray *)scanHeadersForClassDeclarations;

@end
