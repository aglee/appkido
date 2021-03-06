//
//  AKNamedObjectGroup.m
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObjectGroup.h"
#import "DIGSLog.h"
#import "NSArray+AppKiDo.h"

@interface AKNamedObjectGroup ()
@property (copy) NSMutableDictionary *objectsByName;
@end

@implementation AKNamedObjectGroup

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_objectsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark - Getters and setters

- (NSUInteger)objectCount
{
	return self.objectsByName.count;
}

- (NSArray *)sortedObjectNames
{
	return [self.objectsByName.allKeys ak_sortedStrings];
}

- (NSArray *)objects
{
	return self.objectsByName.allValues;
}

- (NSArray *)sortedObjects
{
	return [self.objectsByName.allValues ak_sortedBySortName];
}

#pragma mark - Accessing objects in the group

- (AKNamedObject *)objectWithName:(NSString *)name
{
	return self.objectsByName[name];
}

- (void)addNamedObject:(AKNamedObject *)namedObject
{
	NSParameterAssert(namedObject != nil);
	if (self.objectsByName[namedObject.name]) {
		QLog(@"+++ [ODD] %s Replacing existing object %@ with %@", __PRETTY_FUNCTION__, self.objectsByName[namedObject.name], namedObject);
	}
	self.objectsByName[namedObject.name] = namedObject;
}

- (void)removeNamedObject:(AKNamedObject *)namedObject
{
	[self removeObjectWithName:namedObject.name];
}

- (void)removeObjectWithName:(NSString *)name
{
	self.objectsByName[name] = nil;
}

@end
