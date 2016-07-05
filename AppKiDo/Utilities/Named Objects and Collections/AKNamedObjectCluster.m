//
//  AKNamedObjectCluster.m
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKToken.h"
#import "NSArray+AppKiDo.h"

@interface AKNamedObjectCluster ()
@property (copy) NSMutableDictionary *groupsByName;
@end

@implementation AKNamedObjectCluster

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_groupsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark - Getters and setters

- (NSUInteger)objectCount
{
	NSUInteger totalObjectCount = 0;
	for (AKNamedObjectGroup *group in self.groupsByName.allValues) {
		totalObjectCount += group.objectCount;
	}
	return totalObjectCount;
}

- (NSUInteger)groupCount
{
	return self.groupsByName.count;
}

- (NSArray *)sortedGroupNames
{
	return [self.groupsByName.allKeys ak_sortedStrings];
}

- (NSArray *)sortedGroups
{
	return [self.groupsByName.allValues ak_sortedBySortName];
}

#pragma mark - Accessing groups and objects

- (AKNamedObjectGroup *)groupWithName:(NSString *)groupName
{
	return self.groupsByName[groupName];
}

- (AKNamedObjectGroup *)groupContainingObjectWithName:(NSString *)objectName
{
	for (AKNamedObjectGroup *group in self.groupsByName.allValues) {
		if ([group objectWithName:objectName]) {
			return group;
		}
	}
	return nil;
}

- (void)addNamedObject:(AKNamedObject *)namedObject toGroupWithName:(NSString *)groupName
{
	//QLog(@"+++ Adding object '%@' to group '%@' within cluster '%@'", namedObject.name, groupName, self.name);
	AKNamedObjectGroup *group = self.groupsByName[groupName];
	if (group == nil) {
		group = [[AKNamedObjectGroup alloc] initWithName:groupName];
		self.groupsByName[groupName] = group;
	}
	[group addNamedObject:namedObject];
}

@end
