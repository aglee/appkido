//
//  AKTokenDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKTokenDoc.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"

@implementation AKTokenDoc

#pragma mark - Init/awake/dealloc

- (instancetype)initWithToken:(AKToken *)token
{
	self = [super init];
	if (self) {
		_token = token;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithToken:nil];
}

#pragma mark - AKDoc methods

#pragma mark - AKDoc methods

- (NSString *)docName
{
	return _token.tokenName;
}

- (NSURL *)docURLAccordingToDocSetIndex:(DocSetIndex *)docSetIndex
{
	NSURL *baseURL = docSetIndex.documentsBaseURL;
	NSString *relativePath = self.token.tokenMO.metainformation.file.path;
	if (relativePath == nil) {
		return nil;
	}
	NSURL *docURL = [baseURL URLByAppendingPathComponent:relativePath];
	NSString *anchor = self.token.tokenMO.metainformation.anchor;
	if (anchor) {
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:docURL resolvingAgainstBaseURL:NO];
		urlComponents.fragment = anchor;
		docURL = [urlComponents URL];
	}
	return docURL;
}

@end
