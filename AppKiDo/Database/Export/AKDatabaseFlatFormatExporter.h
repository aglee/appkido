//
//  AKDatabaseFlatFormatExporter.h
//  AppKiDo
//
//  Created by Andy Lee on 6/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabaseLoggingExporter.h"

@class AKDatabase;

/*!
 * Prints a dump of the database that can be used for regression testing.  Can
 * also be used to see what's changed between releases of the docs or the SDK.
 */
@interface AKDatabaseFlatFormatExporter : AKDatabaseLoggingExporter

- (void)printContentsOfDatabase:(AKDatabase *)database;

@end
