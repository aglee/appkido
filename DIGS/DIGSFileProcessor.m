/*
 * DIGSFileProcessor.m
 *
 * Created by Andy Lee on Mon Jul 01 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSFileProcessor.h"

#import "DIGSLog.h"

@interface DIGSFileProcessor ()
@property (nonatomic, copy) NSString *currentPath;
@end

@implementation DIGSFileProcessor

@synthesize basePath = _basePath;
@synthesize currentPath = _currentPath;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithBasePath:(NSString *)basePath
{
    if ((self = [super init]))
    {
        _basePath = [basePath copy];  //TODO: Handle case where basePath is nil.
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithBasePath:@""];
}


#pragma mark - Processing files

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
    self.currentPath = [_basePath stringByAppendingPathComponent:filePath];

    // Do the job.
    [self processCurrentFile];

    // Un-remember the current file.
    [self setCurrentPath:nil];
}

- (void)processDirectory:(NSString *)dirPath recursively:(BOOL)recurseFlag
{
    if (dirPath.length == 0)
    {
        return;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *startPath = [_basePath stringByAppendingPathComponent:dirPath].stringByStandardizingPath;

    for (NSString *filename in [fm contentsOfDirectoryAtPath:startPath error:NULL])
    {
        BOOL isDir;

        [fm changeCurrentDirectoryPath:startPath];
        (void)[fm fileExistsAtPath:filename isDirectory:&isDir];
        if (isDir)
        {
            if (recurseFlag)
            {
                [self processDirectory:[dirPath stringByAppendingPathComponent:filename]
                           recursively:YES];
            }
        }
        else
        {
            NSString *filePath = [dirPath stringByAppendingPathComponent:filename];
            [self processFile:filePath];
        }
    }
}

- (void)processCurrentFile
{
    DIGSLogError_MissingOverride();
}

@end
