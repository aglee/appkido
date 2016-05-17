//
//  AKNamedObjectGroupTopic.m
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObjectGroupTopic.h"
#import "AKNamedObjectGroup.h"

@interface AKNamedObjectGroupTopic ()
@property (strong) AKNamedObjectGroup *namedObjectGroup;
@end

@implementation AKNamedObjectGroupTopic

#pragma mark - Init/awake/dealloc

- (instancetype)initWithNamedObjectGroup:(AKNamedObjectGroup *)namedObjectGroup
{
    self = [super init];
    if (self) {
        _namedObjectGroup = namedObjectGroup;
    }
    return self;
}

#pragma mark - AKTopic methods

- (NSArray *)_arrayWithSubtopics
{
    NSMutableArray *subtopics = [[NSMutableArray alloc] init];

    //TODO: Fill this in.

    return subtopics;
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
    return self.namedObjectGroup.name;
}

@end
