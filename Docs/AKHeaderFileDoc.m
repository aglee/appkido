/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKHeaderFileDoc.h"

NSString *AKHeaderFileDocName = @"Header File";

@implementation AKHeaderFileDoc

#pragma mark - AKTokenItemDoc methods

- (NSURL *)docURLWithBaseURL:(NSURL *)baseURL
{
	NSString *relativePath = self.tokenItem.token.metainformation.declaredIn.headerPath;
	return [baseURL URLByAppendingPathComponent:relativePath];
}

#pragma mark - AKBehaviorGeneralDoc methods

- (NSString *)unqualifiedDocName
{
	return AKHeaderFileDocName;
}

#pragma mark - AKDoc methods

- (AKDocContentType)contentType
{
	return AKDocObjectiveCContentType;
}

@end
