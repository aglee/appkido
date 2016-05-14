//
//  AKNamedObject.m
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

@implementation AKNamedObject

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	NSParameterAssert(name != nil);
	NSParameterAssert(name.length > 0);
	self = [super init];
	if (self) {
		_name = name;
	}
	return self;
}

- (instancetype)init
{
	return [self initWithName:nil];
}

#pragma mark - Getters and setters

- (NSString *)displayName
{
	return self.name;
}

#pragma mark - <AKSortable> methods

- (NSString *)sortName
{
	return self.name;
}

@end
