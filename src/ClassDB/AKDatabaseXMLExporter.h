/*
 *  AKDatabaseXMLExporter.h
 *  AppKiDo
 *
 *  Created by Andy Lee on 12/31/07.
 *  Copyright 2007 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "TCMXMLWriter.h"

@class AKDatabase;

// [agl] TODO Should consider using NSXMLDocument for this.

/*!
 * Exports an AKDatabase to an XML file.
 *
 * The exported information has been useful for debugging and regression
 * testing. It could also be used to see what API changes have occurred in a new
 * release of the Dev Tools.
 */
@interface AKDatabaseXMLExporter : NSObject
{
@private
    AKDatabase *_database;
    TCMXMLWriter *_xmlWriter;
}


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initialzer. */
- (id)initWithDatabase:(AKDatabase *)database fileURL:(NSURL *)outfileURL;


#pragma mark -
#pragma mark The main export method

/*! Exports the database's nodes and frameworks in XML format. */
- (void)doExport;


@end
