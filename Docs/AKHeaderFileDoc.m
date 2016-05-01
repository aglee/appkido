/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKHeaderFileDoc.h"

NSString *AKHeaderFileDocName = @"Header File";

@implementation AKHeaderFileDoc

#pragma mark - AKBehaviorGeneralDoc methods

- (NSString *)unqualifiedDocName
{
	return AKHeaderFileDocName;
}

#pragma mark - AKTokenItemDoc methods

- (NSString *)relativePath
{
	return self.tokenItem.token.metainformation.declaredIn.headerPath;
}

- (BOOL)docTextIsHTML
{
	return NO;
}

@end
