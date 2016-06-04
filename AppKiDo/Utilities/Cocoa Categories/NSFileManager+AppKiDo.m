//
//  NSFileManager+AppKiDo.m
//  AppKiDo
//
//  Created by Andy Lee on 6/3/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "NSFileManager+AppKiDo.h"
#import "DIGSLog.h"

@implementation NSFileManager (AppKiDo)

- (BOOL)ak_isSymlink:(NSString *)path
{
	NSParameterAssert(path != nil);
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	NSDictionary *fileAttributes = [fm attributesOfItemAtPath:path error:&error];

	if (fileAttributes == nil) {
		QLog(@"+++ [ERROR] Could not get file attributes for '%@' -- %@", path, error);
		return NO;
	}

	return ([fileAttributes[NSFileType] isEqualToString:NSFileTypeSymbolicLink]);
}

@end
