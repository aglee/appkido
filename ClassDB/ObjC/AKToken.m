//
// AKToken.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKToken.h"

#import "DIGSLog.h"

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
