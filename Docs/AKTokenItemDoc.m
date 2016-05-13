//
//  AKTokenItemDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKTokenItemDoc.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"

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

#pragma mark - AKDoc methods

- (NSString *)docName
{
	return _tokenItem.tokenName;
}

- (NSURL *)docURLAccordingToDocSetIndex:(DocSetIndex *)docSetIndex
{
	NSURL *baseURL = docSetIndex.documentsBaseURL;
	NSString *relativePath = self.tokenItem.tokenMO.metainformation.file.path;
	if (relativePath == nil) {
		return nil;
	}
	NSURL *docURL = [baseURL URLByAppendingPathComponent:relativePath];
	NSString *anchor = self.tokenItem.tokenMO.metainformation.anchor;
	if (anchor) {
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:docURL resolvingAgainstBaseURL:NO];
		urlComponents.fragment = anchor;
		docURL = [urlComponents URL];
	}
	return docURL;
}

@end
