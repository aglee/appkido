//
// AKDatabaseNode.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKDatabaseNode.h"

#import "DIGSLog.h"

#import "AKFileSection.h"
#import "AKFramework.h"
#import "AKTextUtils.h"

@implementation AKDatabaseNode

#pragma mark -
#pragma mark Factory methods

+ (id)nodeWithNodeName:(NSString *)nodeName owningFramework:(AKFramework *)owningFramework
{
    return [[self alloc] initWithNodeName:nodeName owningFramework:owningFramework];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName owningFramework:(AKFramework *)owningFramework
{
    if ((self = [super init]))
    {
        _nodeName = nodeName;
        _owningFramework = owningFramework;
        _nodeDocumentation = nil;
        _isDeprecated = NO;
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark AKSortable methods

- (NSString *)sortName
{
    return _nodeName;
}


#pragma mark -
#pragma mark NSObject methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: nodeName=%@>", [self className], _nodeName];
}

@end
