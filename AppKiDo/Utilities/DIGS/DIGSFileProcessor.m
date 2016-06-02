/*
 * DIGSFileProcessor.m
 *
 * Created by Andy Lee on Mon Jul 01 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSFileProcessor.h"
#import "DIGSLog.h"

@implementation DIGSFileProcessor

#pragma mark - Processing files

- (void)processRootPath:(NSString *)rootPath
{
	[self _processPath:rootPath depth:0];
}

- (void)processDirectoryAtPath:(NSString *)dirPath depth:(NSInteger)depth
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	NSArray *dirContents = [fm contentsOfDirectoryAtPath:dirPath error:&error];
	if (dirContents == nil) {
		QLog(@"+++ dirContents path [%@], error [%@]", dirPath, error);
		return;
	}
	for (NSString *dirItem in dirContents) {
		NSString *itemPath = [dirPath stringByAppendingPathComponent:dirItem];
		[self _processPath:itemPath depth:(depth + 1)];
	}
}

- (void)processFileAtPath:(NSString *)filePath depth:(NSInteger)depth
{
}

#pragma mark - Private methods

- (void)_processPath:(NSString *)path depth:(NSInteger)depth
{
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir;
	if (![fm fileExistsAtPath:path isDirectory:&isDir]) {
		QLog(@"+++ [ODD] No file at %@", path);
		return;
	}

	if (isDir) {
		[self processDirectoryAtPath:path depth:depth];
	} else {
		[self processFileAtPath:path depth:depth];
	}
}

@end
