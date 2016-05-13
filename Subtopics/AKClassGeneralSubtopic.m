/*
 * AKClassGeneralSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKClassGeneralSubtopic.h"
#import "DIGSLog.h"
#import "AKClassToken.h"

@interface AKClassGeneralSubtopic ()
@property (strong) AKClassToken *classToken;
@end

@implementation AKClassGeneralSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForClassToken:(AKClassToken *)classToken
{
	return [[self alloc] initWithClassToken:classToken];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassToken:(AKClassToken *)classToken
{
	self = [super init];
	if (self) {
		_classToken = classToken;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithClassToken:nil];
}

#pragma mark - AKBehaviorGeneralSubtopic methods

- (AKBehaviorToken *)behaviorToken
{
	return _classToken;
}

@end
