//
//  AKNamedObject.m
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

@implementation AKNamedObject

@synthesize name = _name;

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

- (NSString *)sortName
{
	return self.name;
}

- (NSString *)displayName
{
	return self.name;
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p name=%@>", self.className, self, self.name];
}

@end
