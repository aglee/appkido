/*
 * AKFileUtils.m
 *
 * Created by Andy Lee on Tue May 10 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKFileUtils.h"

@implementation AKFileUtils


#pragma mark -
#pragma mark Existence checking

+ (BOOL)directoryExistsAtPath:(NSString *)path
{
    BOOL isDir = NO;
    BOOL exists =
        [[NSFileManager defaultManager]
            fileExistsAtPath:path
            isDirectory:&isDir];

    return (exists && isDir);
}

+ (NSString *)subdirectoryOf:(NSString *)dir
    withName:(NSString *)subdir
{
    if ((dir == nil) || (subdir == nil))
    {
        return nil;
    }

    NSString *path = [dir stringByAppendingPathComponent:subdir];

    return [self directoryExistsAtPath:path] ? path : nil;
}

+ (NSString *)subdirectoryOf:(NSString *)dir
    withName:(NSString *)subdir1
    orName:(NSString *)subdir2
{
    NSString *path = [self subdirectoryOf:dir withName:subdir1];

    return
        path
        ? path
        : [self subdirectoryOf:dir withName:subdir2];
}

+ (NSString *)subdirectoryOf:(NSString *)dir
    withNameEndingWith:(NSString *)suffix
{
    if ((dir == nil) || (suffix == nil))
    {
        return nil;
    }

	NSArray *dirContents =
        [[NSFileManager defaultManager] directoryContentsAtPath:dir];
	unsigned int i;

	for (i = 0; i < [dirContents count]; i++)
	{
		NSString *f = [dirContents objectAtIndex:i];

		if ([f hasSuffix:suffix])
		{
			NSString *path = [dir stringByAppendingPathComponent:f];

			if ([self directoryExistsAtPath:path])
			{
				return path;
			}
		}
	}

    // If we got this far, we didn't find a match.
	return nil;
}

@end
