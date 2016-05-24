//
//  AKFunctionToken.m
//  AppKiDo
//
//  Created by Andy Lee on 4/25/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKFunctionToken.h"

@implementation AKFunctionToken

#pragma mark - AKNamedObject methods

- (NSString *)displayName
{
	return [self.name stringByAppendingString:@" ( )"];
}

@end
