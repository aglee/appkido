//
// AKDatabaseNode.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKDatabaseNode.h"

#import "DIGSLog.h"

@implementation AKDatabaseNode

#pragma mark -
#pragma mark Factory methods

+ (id)nodeWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    return [[self alloc] initWithNodeName:nodeName
                                 database:database
                            frameworkName:frameworkName];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    if ((self = [super init]))
    {
        _nodeName = nodeName;
        _owningDatabase = database;
        _owningFrameworkName = frameworkName;
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
