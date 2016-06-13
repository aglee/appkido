//
//  AKDatabaseOutlineExporter.h
//  AppKiDo
//
//  Created by Andy Lee on 6/11/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabaseLoggingExporter.h"

@class AKDatabase;

/*!
 * Prints a dump of the database that can be used for regression testing.  Can
 * also be used to see what's changed between releases of the docs or the SDK.
 */
@interface AKDatabaseOutlineExporter : AKDatabaseLoggingExporter

- (void)printOutlineOfFrameworksInDatabase:(AKDatabase *)database;
- (void)printOutlineOfProtocolsInDatabase:(AKDatabase *)database;
- (void)printOutlineOfClassesInDatabase:(AKDatabase *)database;

/*!
 * Convenience method that calls printOutlineOfFrameworksInDatabase:,
 * printOutlineOfProtocolsInDatabase:, and printOutlineOfClassesInDatabase:.
 */
- (void)printFullOutlineOfDatabase:(AKDatabase *)database;

@end
