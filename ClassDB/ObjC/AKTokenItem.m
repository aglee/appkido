//
// AKTokenItem.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKTokenItem.h"

#import "DIGSLog.h"

@implementation AKTokenItem

@dynamic frameworkName;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithToken:(DSAToken *)token
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

#pragma mark - Getters and setters

- (NSString *)tokenName
{
	return self.token.tokenName ?: self.fallbackTokenName;
}

- (NSString *)frameworkName
{
	return [self frameworkNameForToken:self.token];
}

#pragma mark - KLUDGES

- (NSString *)frameworkNameForToken:(DSAToken *)token
{
	NSString *fwName = token.metainformation.declaredIn.frameworkName;

	//TODO: In case this is nil, try to derive framework name from path.

	return fwName;
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
