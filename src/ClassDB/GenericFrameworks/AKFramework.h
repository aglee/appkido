/*
 * AKFramework.h
 *
 * Created by Andy Lee on Sun Jun 20 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "AKSortable.h"

@class AKDatabase;
@class AKGroupNode;

// [agl] TODO -- Class comment needs to be updated to reflect docset support.

/*!
 * @class       AKFramework
 * @abstract    Contains information about a framework.
 * @discussion  An AKFramework contains information about the API and
 *              documentation for a Mac OS X framework -- typically (if not
 *              always) a framework that lives in /System/Library/Frameworks.
 *
 *              AKFramework is an abstract class.  Subclasses represent
 *              frameworks for which different kinds of API information may be
 *              relevant.  For example, classes and protocols are relevant to
 *              Objective-C frameworks, but not to plain C frameworks.  This
 *              difference is reflected in the AKCFramework and AKObjCFramework
 *              classes.
 *
 *              Subclasses of AKFramework also represent different "styles"
 *              for organizing API documentation.  For example, a Cocoa
 *              framework such as Foundation has all its C functions
 *              documented in one HTML file.  The documentation for
 *              CoreFoundation, however, organizes everything into
 *              subdirectories, each of which contains one or more HTML
 *              files containing function documentation.  (NOTE: as of this
 *              writing, AppKiDo only supports the Cocoa "style" of
 *              documentation.)
 *
 *              In some cases, a framework's documentation is organized
 *              differently on different versions of the Developer Tools.
 *              For example, in Tiger the CoreFoundation documents changed
 *              from using file names that indicate the files' contents
 *              to using file names that indicate a chapter number.
 */
@interface AKFramework : NSObject <AKSortable>
{
@protected
    NSString *_frameworkName;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*!
 * @method      initWithName:
 * @discussion  Designated initializer.
 */
- (id)initWithName:(NSString *)fwName;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)frameworkName;

//-------------------------------------------------------------------------
// Populating a database
//-------------------------------------------------------------------------

/*!
 * @method      populateDatabase:
 * @discussion  Parses the HTML and header files for the receiver.  As API
 *              constructs are discovered, nodes for those constructs are
 *              added to the specified database.
 *
 *              Subclasses must override this method.
 */
- (void)populateDatabase:(AKDatabase *)db;

//-------------------------------------------------------------------------
// AKSortable methods
//-------------------------------------------------------------------------

/*!
 * @method      sortName
 * @discussion  Returns the framework name.
 */
- (NSString *)sortName;

@end
