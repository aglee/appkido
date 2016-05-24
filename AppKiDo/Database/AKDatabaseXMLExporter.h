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

//TODO: Consider using NSXMLDocument for this?  Does that make sense?

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

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)database fileURL:(NSURL *)outfileURL NS_DESIGNATED_INITIALIZER;

#pragma mark - The main export method

/*! Exports the database in XML format. */
- (void)doExport;


@end
