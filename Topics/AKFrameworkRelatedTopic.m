//
//  AKFrameworkRelatedTopic.m
//  AppKiDo
//
//  Created by Andy Lee on 5/20/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKFrameworkRelatedTopic.h"
#import "AKFramework.h"

@implementation AKFrameworkRelatedTopic

@synthesize framework = _framework;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(AKFramework *)framework
{
	NSParameterAssert(framework != nil);
	self = [super init];
	if (self) {
		_framework = framework;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithFramework:nil];
}

@end
