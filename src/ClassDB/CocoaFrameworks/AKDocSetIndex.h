/*
 *  AKDocSetIndex.h
 *
 *  Created by Andy Lee on 1/6/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * Provides read-only access to the SQLite database of API tokens that can be
 * found inside a .docset bundle.  The database is in a file called docSet.dsidx.
 */
@interface AKDocSetIndex : NSObject

#pragma mark -
#pragma mark Init/awake/dealloc

/*!
 * Designated initializer.  docSetPath is the path to a .docset bundle
 * (i.e., should end with .docset).  basePathForHeaders is the path to the
 * path that the header paths in the docset index (as given by the sqlite
 * file) should be relative to.
 *
 * Returns nil if the docset path or base path for headers is missing or
 * not a directory.
 */
- (id)initWithDocSetPath:(NSString *)docSetPath basePathForHeaders:(NSString *)basePathForHeaders;


#pragma mark -
#pragma mark Getters and setters

- (NSString *)docSetPath;

/*! 
 * Names of frameworks the user can choose from, with "essential"
 * frameworks forced to the beginning of the list but otherwise in
 * alphabetical order.  (See AKNamesOfEssentialFrameworks.)
 */
- (NSArray *)selectableFrameworkNames;

/*!
 * The header paths returned by the headerPathsForFramework: are relative
 * to this directory.
 */
- (NSString *)basePathForHeaders;

/*! Returns absolute directories containing header files. */
- (NSSet *)headerDirsForFramework:(NSString *)frameworkName;

/*! Returns paths relative to -basePathForHeaders. */
- (NSArray *)headerPathsForFramework:(NSString *)frameworkName;

/*!
 * The doc paths returned by the xxxDocPathsForFramework: methods are relative
 * to this directory.
 */
- (NSString *)baseDirForDocs;

/*!
 * Class docs, protocol docs, "FrameworkX ClassY Additions" docs, deprecated
 * method/class docs.
 *
 * Returns paths relative to -baseDirForDocs.
 */
- (NSArray *)behaviorDocPathsForFramework:(NSString *)frameworkName;

/*! Returns paths relative to -baseDirForDocs. */
- (NSArray *)functionsDocPathsForFramework:(NSString *)frameworkName;

/*! Returns paths relative to -baseDirForDocs. */
- (NSArray *)globalsDocPathsForFramework:(NSString *)frameworkName;

@end
