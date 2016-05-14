//
//  AKClassMethodToken.m
//  AppKiDo
//
//  Created by Andy Lee on 5/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKClassMethodToken.h"

@implementation AKClassMethodToken

#pragma mark - AKMemberToken methods

- (NSString *)punctuatedName
{
	return [@"+" stringByAppendingString:self.name];
}

@end
