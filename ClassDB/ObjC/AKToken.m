//
// AKToken.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKToken.h"
#import "AKRegexUtils.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"

@implementation AKToken

@synthesize tokenMO = _tokenMO;
@synthesize frameworkName = _frameworkName;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
	NSParameterAssert(tokenMO != nil);
	self = [super initWithName:tokenMO.tokenName];
	if (self) {
		[self _takeIvarValuesFromTokenMO:tokenMO];
	}
	return self;
}

#pragma mark - Getters and setters

{
- (DSAToken *)tokenMO
{
	return _tokenMO;
}

- (void)setTokenMO:(DSAToken *)tokenMO
{
	[self _takeIvarValuesFromTokenMO:tokenMO];
}

- (void)_takeIvarValuesFromTokenMO:(DSAToken *)tokenMO
{
	_tokenMO = tokenMO;
	_frameworkName = [self _frameworkNameForTokenMO:tokenMO];
}

- (NSString *)_frameworkNameForTokenMO:(DSAToken *)tokenMO
{
	// See if the DocSetIndex specifies a framework for this token.
	NSString *frameworkName = tokenMO.metainformation.declaredIn.frameworkName;
	if (frameworkName) {
		//QLog(@"+++ Framework %@ for %@ was explicit", frameworkName, self);
	}

	// See if we can infer the framework name from the headerPath.
	if (frameworkName == nil) {
		NSString *headerPath = tokenMO.metainformation.declaredIn.headerPath;
		if (headerPath) {
			NSDictionary *captureGroups = [AKRegexUtils matchPattern:@".*/(%ident%)\\.framework/.*" toEntireString:headerPath];
			frameworkName = captureGroups[@1];
			if (frameworkName) {
				QLog(@"+++ Framework %@ for %@ was inferred from header path", frameworkName, self);
			}
		}
	}

	//TODO: Failing that, try to infer framework name from doc path and maybe doc file name.

	return frameworkName;
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
