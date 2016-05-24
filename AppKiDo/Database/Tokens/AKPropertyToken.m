//
//  AKPropertyToken.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKPropertyToken.h"

@implementation AKPropertyToken

#pragma mark - AKMemberToken methods

- (NSString *)punctuatedName
{
	return [@"." stringByAppendingString:self.name];
}

@end
