/*
 * AKDoc.m
 *
 * Created by Andy Lee on Mon Mar 15 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDoc.h"
#import "DIGSLog.h"

@implementation AKDoc

- (NSURL *)docURLWithBasePath:(NSString *)basePath
{
	DIGSLogError_MissingOverride();
	return nil;
}

#pragma mark - Getters and setters

- (BOOL)docTextIsHTML
{
	DIGSLogError_MissingOverride();
	return YES;
}

- (NSString *)docName
{
	DIGSLogError_MissingOverride();
	return nil;
}

- (NSString *)stringToDisplayInDocList
{
	return self.docName;
}

- (NSString *)commentString
{
	return @"";
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: docName=%@>", self.className, self.docName];
}

@end
