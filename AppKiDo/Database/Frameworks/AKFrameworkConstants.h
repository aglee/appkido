/*
 * AKFrameworkConstants.h
 *
 * Created by Andy Lee on Wed Mar 31 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

#pragma mark - Frameworks that we give special treatment

extern NSString *AKFoundationFrameworkName;
extern NSString *AKAppKitFrameworkName;
extern NSString *AKUIKitFrameworkName;
extern NSString *AKCoreDataFrameworkName;
extern NSString *AKCoreImageFrameworkName;
extern NSString *AKQuartzCoreFrameworkName;

/*!
 * Returns the names of frameworks that must be loaded into the database
 * if available within the docset for that database.  These frameworks must
 * be loaded first and in the order given.  Order is important because the
 * first framework seen for a item is considered to be the item's primary
 * framework.
 */
extern NSArray *_AKNamesOfEssentialFrameworks();

#define AKNamesOfEssentialFrameworks _AKNamesOfEssentialFrameworks()
