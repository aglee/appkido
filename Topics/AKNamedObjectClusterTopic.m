//
//  AKNamedObjectClusterTopic.m
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObjectClusterTopic.h"
#import "AKSubtopic.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"

@interface AKNamedObjectClusterTopic ()
@property (strong) AKNamedObjectCluster *namedObjectCluster;
@end

@implementation AKNamedObjectClusterTopic

#pragma mark - Init/awake/dealloc

- (instancetype)initWithNamedObjectCluster:(AKNamedObjectCluster *)namedObjectCluster
{
    self = [super init];
    if (self) {
        _namedObjectCluster = namedObjectCluster;
    }
    return self;
}

#pragma mark - AKTopic methods

- (NSArray *)_arrayWithSubtopics
{
    NSMutableArray *subtopics = [[NSMutableArray alloc] init];
    for (AKNamedObjectGroup *namedObject in self.namedObjectCluster.sortedGroups) {
        AKSubtopic *subtopic = [[AKSubtopic alloc] initWithName:namedObject.name
                                                   docListItems:namedObject.sortedObjects];
        [subtopics addObject:subtopic];
    }
    return subtopics;
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
    return self.namedObjectCluster.name;
}

@end
