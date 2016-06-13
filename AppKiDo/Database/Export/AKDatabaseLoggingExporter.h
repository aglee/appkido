//
//  AKDatabaseLoggingExporter.h
//  AppKiDo
//
//  Created by Andy Lee on 6/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKDatabase;

@interface AKDatabaseLoggingExporter : NSObject

- (void)printMetadataForDatabase:(AKDatabase *)database;

@end
