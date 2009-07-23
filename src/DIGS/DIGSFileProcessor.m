/*
 * DIGSFileProcessor.m
 *
 * Created by Andy Lee on Mon Jul 01 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <DIGSFileProcessor.h>

#import "DIGSLog.h"

@implementation DIGSFileProcessor


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithBasePath:(NSString *)basePath
{
    if ((self = [super init]))
    {
        // [agl] TODO handle case where basePath is nil
        _basePath = [basePath retain];
    }
    
    return self;
}

- (id)init
{
    return [self initWithBasePath:@""];
}

- (void)dealloc
{
    [_basePath release];
    [_currentPath release];

    [super dealloc];
}


#pragma mark -
#pragma mark Getters and setters

- (NSString *)basePath
{
    return _basePath;
}

- (NSString *)currentPath
{
    return _currentPath;
}


#pragma mark -
#pragma mark Processing files

- (BOOL)shouldProcessFile:(NSString *)filePath
{
    return YES;
}

- (void)processFile:(NSString *)filePath
{
    // Apply our filter to the file path.
    if ([self shouldProcessFile:filePath])
    {
        DIGSLogDebug2(@"processing file [%@]", filePath);
    }
    else
    {
        DIGSLogDebug(@"skipping file [%@]", filePath);
        return;
    }

    // Remember the current file.
    _currentPath = [[_basePath stringByAppendingPathComponent:filePath] retain];

    // Do the job.
    [self processCurrentFile];

    // Un-remember the current file.
    [_currentPath release];
    _currentPath = nil;
}

- (void)processDirectory:(NSString *)dirPath recursively:(BOOL)recurseFlag
{
    if ((dirPath == nil) || ([dirPath length] == 0))
    {
        return;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSEnumerator *en;
    NSString *filename;
    NSString *startPath =
        [[_basePath stringByAppendingPathComponent:dirPath]
            stringByStandardizingPath];
    en = [[fm directoryContentsAtPath:startPath] objectEnumerator];
    while ((filename = [en nextObject]))
    {
        BOOL isDir;

        [fm changeCurrentDirectoryPath:startPath];
        (void)[fm fileExistsAtPath:filename isDirectory:&isDir];
        if (isDir)
        {
            if (recurseFlag)
            {
                [self
                    processDirectory:
                        [dirPath stringByAppendingPathComponent:filename]
                    recursively:YES];
            }
        }
        else
        {
            filename = [dirPath stringByAppendingPathComponent:filename];
            [self processFile:filename];
        }
    }
}

- (void)processCurrentFile
{
    DIGSLogError_MissingOverride();
}

@end
