/*
 * AKClassGeneralSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKClassGeneralSubtopic.h"
#import "DIGSLog.h"
#import "AKClassItem.h"

@interface AKClassGeneralSubtopic ()
@property (strong) AKClassItem *classItem;
@end

@implementation AKClassGeneralSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForClassItem:(AKClassItem *)classItem
{
	return [[self alloc] initWithClassItem:classItem];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassItem:(AKClassItem *)classItem
{
	self = [super init];
	if (self) {
		_classItem = classItem;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithClassItem:nil];
}

#pragma mark - AKBehaviorGeneralSubtopic methods

- (AKBehaviorToken *)behaviorToken
{
	return _classItem;
}

@end
