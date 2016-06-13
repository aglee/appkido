//
//  AKDatabaseLoggingExporter.m
//  AppKiDo
//
//  Created by Andy Lee on 6/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabaseLoggingExporter.h"
#import "AKDatabase.h"
#import "AKInstalledSDK.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"

@implementation AKDatabaseLoggingExporter

- (void)printMetadataForDatabase:(AKDatabase *)database
{
	NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
														  dateStyle:NSDateFormatterFullStyle
														  timeStyle:NSDateFormatterMediumStyle];
	DIGSPrintTabIndented(0, @"%@", dateString);
	DIGSPrintTabIndented(0, @"Docset for platform %@, version %@",
						 database.docSetIndex.platformInternalName,
						 database.docSetIndex.platformVersion);
	DIGSPrintTabIndented(0, (@"SDK for platform %@, version %@"
							 @"\n"),
						 database.referenceSDK.platformInternalName,
						 database.referenceSDK.sdkVersion);
}

@end
