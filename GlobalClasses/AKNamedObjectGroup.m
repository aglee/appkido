//
//  AKNamedObjectGroup.m
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObjectGroup.h"
#import "AKSortUtils.h"
#import "QuietLog.h"

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

- (NSArray *)sortedObjectNames
{
	return [self.objectsByName.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *)sortedObjects
{
	return [AKSortUtils arrayBySortingArray:self.objectsByName.allValues];
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
		QLog(@"+++ [ODD] %s Replacing existing object with %@", namedObject);
	}
	self.objectsByName[namedObject.name] = namedObject;
}

@end
