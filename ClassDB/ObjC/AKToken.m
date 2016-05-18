//
// AKToken.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKToken.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"

@implementation AKToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
	NSParameterAssert(tokenMO != nil);
	self = [super initWithName:tokenMO.tokenName];
	if (self) {
		_tokenMO = tokenMO;
	}
	return self;
}

#pragma mark - Getters and setters

- (NSString *)headerPath
{
	return self.tokenMO.metainformation.declaredIn.headerPath;
}

#pragma mark - <AKDocListItem> methods

- (NSString *)commentString
{
	return @"";
}

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

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: name=%@>", self.className, self.name];
}

@end
