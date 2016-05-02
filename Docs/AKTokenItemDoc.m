//
//  AKTokenItemDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKTokenItemDoc.h"
#import "DIGSLog.h"

@implementation AKTokenItemDoc

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenItem:(AKTokenItem *)tokenItem
{
	self = [super init];
	if (self) {
		_tokenItem = tokenItem;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithTokenItem:nil];
}

#pragma mark - AKTokenItemDoc methods

- (NSURL *)docURLWithBaseURL:(NSURL *)baseURL
{
	NSString *relativePath = self.tokenItem.token.metainformation.file.path;
	if (relativePath == nil) {
		return nil;
	}
	NSURL *docURL = [baseURL URLByAppendingPathComponent:relativePath];
	NSString *anchor = self.tokenItem.token.metainformation.anchor;
	if (anchor) {
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:docURL resolvingAgainstBaseURL:NO];
		urlComponents.fragment = anchor;
		docURL = [urlComponents URL];
	}
	return docURL;
}

#pragma mark - AKDoc methods

- (AKDocContentType)contentType
{
	return AKDocHTMLContentType;
}

- (NSString *)docName
{
	return _tokenItem.tokenName;
}

@end
