/*
 * DIGSFileProcessor.m
 *
 * Created by Andy Lee on Mon Jul 01 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <DIGSFileProcessor.h>

#import <DIGSLog.h>

@implementation DIGSFileProcessor

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithBasePath:(NSString *)basePath
{
    if ((self = [super init]))
    {
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
    [_currentRelativePath release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)basePath
{
    return _basePath;
}

- (NSString *)currentRelativePath
{
    return _currentRelativePath;
}

- (NSString *)currentPath
{
    return [_basePath stringByAppendingPathComponent:_currentRelativePath];
}

//-------------------------------------------------------------------------
// Processing files
//-------------------------------------------------------------------------

- (BOOL)shouldProcessFile:(NSString *)filePath
{
    return YES;
}

- (void)processFile:(NSString *)filePath
{
    // Apply our filter to the file path.
    if ([self shouldProcessFile:filePath])
    {
        DIGSLogDebug(@"processing file [%@]", filePath);
    }
    else
    {
        DIGSLogDebug(@"skipping file [%@]", filePath);
        return;
    }

    // Remember the current file.
    _currentRelativePath = [filePath retain];

    // Do the job.
    [self processCurrentFile];

    // Un-remember the current file.
    [_currentRelativePath release];
    _currentRelativePath = nil;
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
    DIGSLogMissingOverride();
}

@end
