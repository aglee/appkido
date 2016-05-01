/*
 * AKInstanceMethodDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKInstanceMethodDoc.h"

@implementation AKInstanceMethodDoc

#pragma mark - AKMemberDoc methods

+ (NSString *)punctuateTokenName:(NSString *)tokenName
{
	return [@"-" stringByAppendingString:tokenName];
}

@end
