/*
 * AKFramework.m
 *
 * Created by Andy Lee on Sun Jun 20 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKFramework.h"

#import <DIGSLog.h>
#import "AKDatabase.h"


@implementation AKFramework

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithName:(NSString *)fwName
{
    if ((self = [super init]))
    {
        _frameworkName = [fwName retain];
    }

    return self;
}

- (id)init
{
    DIGSLogNondesignatedInitializer();
    [self dealloc];
    return nil;
}

- (void)dealloc
{
    [_frameworkName release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)frameworkName
{
    return _frameworkName;
}

//-------------------------------------------------------------------------
// Populating a database
//-------------------------------------------------------------------------

- (void)populateDatabase:(AKDatabase *)db
{
    DIGSLogMissingOverride();
}

//-------------------------------------------------------------------------
// AKSortable methods
//-------------------------------------------------------------------------

- (NSString *)sortName
{
    return _frameworkName;
}

@end
