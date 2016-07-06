//
//  AKHeaderScanner.h
//  AppKiDo
//
//  Created by Andy Lee on 6/2/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKClassDeclarationInfo;
@class AKInstalledSDK;

/*!
 * For internal use by AKDatabase.
 *
 * Scans the frameworks in the SDK's System/Library/Frameworks directory.  Each
 * framework is a directory whose name has the form "FRAMEWORKNAME.framework".
 *
 * Gets framework names by removing the ".framework" extension from the
 * framework directory names.
 *
 * Finds class declarations by scanning the .h files in the framework
 * directories, looking for the pattern "@interface SomeClass : SomeSuperclass".
 */
@interface AKHeaderScanner : NSObject

@property (copy, readonly) NSArray *frameworkNames;
@property (copy, readonly) NSArray<AKClassDeclarationInfo *> *classDeclarations;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithInstalledSDK:(AKInstalledSDK *)installedSDK NS_DESIGNATED_INITIALIZER;

@end
