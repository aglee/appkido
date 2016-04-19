//
//  AKFileSectionCache.m
//  AppKiDo
//
//  Created by Andy Lee on 2/25/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKFileSectionCache.h"

@implementation AKFileSectionCache

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _fileCache = [[NSMutableDictionary alloc] init];
        _fileCacheCounts = [[NSMutableDictionary alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Accessing the cache

- (NSData *)likeFileAtPath:(NSString *)filePath
{
    NSData *fileContents = _fileCache[filePath];

    if (fileContents)
    {
        // The file is already in the cache. Increment the "like" count.
        NSNumber *cacheCountObj = _fileCacheCounts[filePath];

        if (cacheCountObj == nil) abort();

        int cacheCount = cacheCountObj.intValue;

        _fileCacheCounts[filePath] = @(cacheCount + 1);
    }
    else
    {
        // The file wasn't in the cache. Add it with a "like" count of 1.
        fileContents = [[NSData alloc] initWithContentsOfFile:filePath];

        if (fileContents)
        {
            _fileCache[filePath] = fileContents;
            _fileCacheCounts[filePath] = @1;
        }
    }

    return fileContents;
}

- (void)unlikeFileAtPath:(NSString *)filePath
{
    NSNumber *cacheCountObj = _fileCacheCounts[filePath];

    if (cacheCountObj == nil)
    {
        return;
    }

    int cacheCount = cacheCountObj.intValue;

    if (cacheCount == 1)
    {
        // This was the last reference -- remove the file from the cache.
        [_fileCache removeObjectForKey:filePath];
        [_fileCacheCounts removeObjectForKey:filePath];
    }
    else
    {
        // This was not the last "like". Just decrement the cache count.
        _fileCacheCounts[filePath] = @(cacheCount - 1);
    }
}

@end
