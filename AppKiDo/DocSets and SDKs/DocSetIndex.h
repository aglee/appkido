//
//  DocSetIndex.h
//  AppKiDo
//
//  Created by Andy Lee on 4/17/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocSetModel.h"

@interface DocSetIndex : NSObject

/*! Path to a .docset directory. */
@property (readonly, copy, nonatomic) NSString *docSetPath;
@property (readonly, copy, nonatomic) NSString *docSetInternalName;
@property (readonly, copy, nonatomic) NSString *docSetDisplayName;
@property (readonly, copy, nonatomic) NSString *bundleIdentifier;
/*! The platform name Apple uses in plists for docsets and SDKs. */
@property (readonly, copy, nonatomic) NSString *platformInternalName;
@property (readonly) NSString *platformDisplayName;
@property (readonly, copy, nonatomic) NSString *platformVersion;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, copy, nonatomic) NSURL *documentsBaseURL;

#pragma mark - Finding installed docsets

/*!
 * Looks in the directory's immediate (non-recursive) contents for things that look like
 * docsets.
 */
+ (NSArray *)sortedDocSetsInDirectory:(NSString *)docSetsContainerPath;

/*!
 * Looks in the standard location where Xcode installs docsets, which is
 * "~/Library/Developer/Shared/Documentation/DocSets".  The returned array is
 * sorted by platform and version.
 */
+ (NSArray *)sortedDocSetsInStandardLocation;

/*!
 * Expects `xcodeAppPath` to point to an Xcode app bundle, e.g. "/Applications/Xcode.app".
 * Currently this works with Xcode 7.3.1, which includes docsets in the bundle.  I think
 * Xcode 6 may still have required a separate download which installed the docs in
 * "~/Library/Developer/Shared/Documentation/DocSets", but I don't remember for sure when
 * they started including docs in the Xcode app bundle instead of requiring the separate
 * download.
 */
+ (NSArray *)sortedDocSetsWithinXcodePath:(NSString *)xcodeAppPath;

#pragma mark - Init/awake/dealloc

/*! docSetPath must be a path to a .docset bundle. */
- (instancetype)initWithDocSetPath:(NSString *)docSetPath NS_DESIGNATED_INITIALIZER;

@end
