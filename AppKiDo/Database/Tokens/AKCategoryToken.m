//
// AKCategoryToken.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKCategoryToken.h"
#import "AKClassToken.h"

@implementation AKCategoryToken

#pragma mark - AKBehaviorToken methods

- (void)tearDown
{
	[super tearDown];

	self.owningClassToken = nil;
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %@(%@)>",
			self.className,
			self.owningClassToken.name,
			self.name];
}

#pragma mark - <AKNamed> methods

- (NSString *)displayName
{
	return [NSString stringWithFormat:@"%@(%@)", self.owningClassToken.name, self.name];
}

@end
