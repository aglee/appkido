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

#pragma mark - AKDoc methods

- (NSURL *)docURLWithBasePath:(NSString *)basePath
{
	NSString *path = [basePath stringByAppendingPathComponent:self.tokenItem.token.metainformation.file.path];
	NSString *anchor = self.tokenItem.token.metainformation.anchor;
	NSURL *url = [NSURL fileURLWithPath:path];

	if (anchor) {
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
		urlComponents.fragment = anchor;
		url = [urlComponents URL];
	}

	return url;
}

- (BOOL)docTextIsHTML
{
	return YES;
}

- (NSString *)docName
{
	return _tokenItem.tokenName;
}

@end
