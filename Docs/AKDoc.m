/*
 * AKDoc.m
 *
 * Created by Andy Lee on Mon Mar 15 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDoc.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"

@implementation AKDoc

#pragma mark - Getters and setters

- (NSString *)docName
{
	DIGSLogError_MissingOverride();
	return nil;
}

- (NSString *)displayName
{
	return self.docName;
}

- (NSString *)commentString
{
	return @"";
}

#pragma mark - URLs

- (NSURL *)docURLAccordingToDocSetIndex:(DocSetIndex *)docSetIndex
{
	DIGSLogError_MissingOverride();
	return nil;
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: docName=%@>", self.className, self.docName];
}

@end
