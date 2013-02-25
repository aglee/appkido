//
// AKDatabaseNode.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKDatabaseNode.h"

#import "DIGSLog.h"

@implementation AKDatabaseNode

@synthesize nodeName = _nodeName;
@synthesize owningDatabase = _owningDatabase;
@synthesize owningFrameworkName = _owningFrameworkName;
@synthesize nodeDocumentation = _nodeDocumentation;
@synthesize isDeprecated = _isDeprecated;

#pragma mark -
#pragma mark Factory methods

+ (id)nodeWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    return [[[self alloc] initWithNodeName:nodeName
                                  database:database
                             frameworkName:frameworkName] autorelease];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    if ((self = [super init]))
    {
        _nodeName = [nodeName copy];
        _owningDatabase = database;
        _owningFrameworkName = [frameworkName copy];
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

- (void)dealloc
{
    [_nodeName release];
    [_owningFrameworkName release];
    [_nodeDocumentation release];

    [super dealloc];
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
