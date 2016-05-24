//
//  AKFramework.m
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKFramework.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKTopicConstants.h"

@implementation AKFramework

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_protocolsGroup = [[AKNamedObjectGroup alloc] initWithName:AKProtocolsTopicName];
		_constantsCluster = [[AKNamedObjectCluster alloc] initWithName:AKConstantsTopicName];
		_enumsCluster = [[AKNamedObjectCluster alloc] initWithName:AKEnumsTopicName];
		_functionsCluster = [[AKNamedObjectCluster alloc] initWithName:AKFunctionsTopicName];
		_macrosCluster = [[AKNamedObjectCluster alloc] initWithName:AKMacrosTopicName];
		_typedefsCluster = [[AKNamedObjectCluster alloc] initWithName:AKTypedefsTopicName];
	}
	return self;
}

@end
