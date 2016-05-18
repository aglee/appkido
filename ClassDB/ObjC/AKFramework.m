//
//  AKFramework.m
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKFramework.h"
#import "AKNamedObjectCluster.h"

@implementation AKFramework

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _constantsCluster = [[AKNamedObjectCluster alloc] initWithName:@"Constants"];
        _enumsCluster = [[AKNamedObjectCluster alloc] initWithName:@"Enums"];
        _functionsCluster = [[AKNamedObjectCluster alloc] initWithName:@"Functions"];
        _macrosCluster = [[AKNamedObjectCluster alloc] initWithName:@"Macros"];
        _typedefsCluster = [[AKNamedObjectCluster alloc] initWithName:@"Typedefs"];
    }
    return self;
}

@end
