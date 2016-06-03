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

- (NSString *)headerPathRelativeToSDK
{
	return self.tokenMO.metainformation.declaredIn.headerPath;
}

- (BOOL)hasHeader
{
	return (self.fullHeaderPathOutsideOfSDK != nil
			|| self.headerPathRelativeToSDK != nil);
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: name=%@ type=%@>", self.className, self.name, self.tokenMO.tokenType.typeName];
}

@end
