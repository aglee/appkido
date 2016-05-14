//
// AKToken.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKToken.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"

@implementation AKToken

@dynamic frameworkName;

#pragma mark - Getters and setters

- (NSString *)tokenName
{
	return self.tokenMO.tokenName;
}

- (NSString *)frameworkName
{
	//TODO: In case this is nil, try to derive framework name from path.
	return self.tokenMO.metainformation.declaredIn.frameworkName;
}

- (NSString *)commentString
{
	return @"";
}

#pragma mark - URLs

- (NSURL *)docURLAccordingToDocSetIndex:(DocSetIndex *)docSetIndex
{
	NSURL *baseURL = docSetIndex.documentsBaseURL;
	NSString *relativePath = self.tokenMO.metainformation.file.path;
	if (relativePath == nil) {
		return nil;
	}
	NSURL *docURL = [baseURL URLByAppendingPathComponent:relativePath];
	NSString *anchor = self.tokenMO.metainformation.anchor;
	if (anchor) {
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:docURL resolvingAgainstBaseURL:NO];
		urlComponents.fragment = anchor;
		docURL = [urlComponents URL];
	}
	return docURL;
}

#pragma mark - AKNamedObject methods

- (NSString *)name
{
	return self.tokenName;  //TODO: Clean this up.
}

#pragma mark - AKSortable methods

- (NSString *)sortName
{
	return self.tokenName;
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: tokenName=%@>", self.className, self.tokenName];
}

@end
