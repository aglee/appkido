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
		_functionsAndGlobalsCluster = [[AKNamedObjectCluster alloc] initWithName:AKFunctionsAndGlobalsTopicName];
	}
	return self;
}

@end
