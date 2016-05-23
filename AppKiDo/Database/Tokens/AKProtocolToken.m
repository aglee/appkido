//
// AKProtocolToken.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKProtocolToken.h"

@implementation AKProtocolToken

#pragma mark - <AKNamed> methods

- (NSString *)displayName
{
	return [NSString stringWithFormat:@"<%@>", self.name];
}

@end
