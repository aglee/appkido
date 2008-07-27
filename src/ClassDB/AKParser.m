/*
 * AKParser.m
 *
 * Created by Andy Lee on Sat Mar 06 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKParser.h"

#import <DIGSLog.h>
#import "AKDatabase.h"
#import "AKFramework.h"

@implementation AKParser

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithDatabase:(AKDatabase *)db
    frameworkName:(NSString *)frameworkName
{
    if ((self = [super init]))
    {
        _databaseBeingPopulated = [db retain];
        _frameworkName = [frameworkName retain];
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
    [_databaseBeingPopulated release];
    [_frameworkName release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Parsing
//-------------------------------------------------------------------------

- (NSMutableData *)loadDataToBeParsed
{
    return [NSMutableData dataWithContentsOfFile:[self currentPath]];
}

- (void)parseCurrentFile
{
    DIGSLogMissingOverride();
}

//-------------------------------------------------------------------------
// DIGSFileProcessor methods
//-------------------------------------------------------------------------

// Sets things up for -parseCurrentFile to do the real work.
- (void)processCurrentFile
{
    // Set up.
    NSMutableData *fileContents = [self loadDataToBeParsed];

    if (fileContents)
    {
        _dataStart = [fileContents bytes];
        _current = _dataStart;
        _dataEnd = _dataStart + [fileContents length];
    }
    else
    {
        _dataStart = NULL;
        _current = NULL;
        _dataEnd = NULL;
    }

    // Do the job.
    [self parseCurrentFile];

    // Clean up.
    _dataStart = NULL;
    _current = NULL;
    _dataEnd = NULL;
}

@end
