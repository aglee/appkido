/*
 *  AKDatabaseXMLExporter.h
 *  AppKiDo
 *
 *  Created by Andy Lee on 12/31/07.
 *  Copyright 2007 Andy Lee. All rights reserved.
 */

#import "AKDatabaseExporter.h"

@class AKDatabase;

/*!
 * class        AKDatabaseXMLExporter
 * @discussion  Support for exporting an AKDatabase to an XML file.
 */
@interface AKDatabaseXMLExporter : AKDatabaseExporter
{
@private
    // The following are used only used during export.
    int _indent;
}

@end
