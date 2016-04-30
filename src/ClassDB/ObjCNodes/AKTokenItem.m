//
// AKTokenItem.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKTokenItem.h"

#import "DIGSLog.h"

@implementation AKTokenItem

#pragma mark -
#pragma mark Factory methods

+ (instancetype)nodeWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    return [[self alloc] initWithNodeName:nodeName database:database frameworkName:frameworkName];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    if ((self = [super init]))
    {
        _nodeName = [nodeName copy];
        _owningDatabase = database;
        _nameOfOwningFramework = [frameworkName copy];
        _nodeDocumentation = nil;
        _isDeprecated = NO;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithNodeName:nil database:nil frameworkName:nil];
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
    return [NSString stringWithFormat:@"<%@: nodeName=%@>", self.className, _nodeName];
}

@end
