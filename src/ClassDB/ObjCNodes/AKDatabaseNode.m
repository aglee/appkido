//
// AKDatabaseNode.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKDatabaseNode.h"

#import "DIGSLog.h"

#import "AKTextUtils.h"
#import "AKClassNode.h"
#import "AKFileSection.h"

@implementation AKDatabaseNode

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)nodeWithNodeName:(NSString *)nodeName
    owningFramework:(NSString *)fwName
{
    return
        [[[self alloc]
            initWithNodeName:nodeName
            owningFramework:fwName] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(NSString *)fwName
{
    if ((self = [super init]))
    {
        _nodeName = [nodeName retain];
        _owningFramework = [fwName retain];
        _nodeDocumentation = nil;
        _isDeprecated = NO;
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_nodeName release];
    [_owningFramework release];
    [_nodeDocumentation release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)nodeName
{
    return _nodeName;
}

- (NSString *)owningFramework
{
    return _owningFramework;
}

- (void)setOwningFramework:(NSString *)frameworkName
{
    [frameworkName retain];
    [_owningFramework release];
    _owningFramework = frameworkName;
}

- (AKFileSection *)nodeDocumentation
{
    return _nodeDocumentation;
}

- (void)setNodeDocumentation:(AKFileSection *)fileSection
{
    [fileSection retain];
    [_nodeDocumentation release];
    _nodeDocumentation = fileSection;
}

- (BOOL)isDeprecated
{
    return _isDeprecated;
}

- (void)setIsDeprecated:(BOOL)isDeprecated
{
    _isDeprecated = isDeprecated;
}

//-------------------------------------------------------------------------
// AKSortable methods
//-------------------------------------------------------------------------

- (NSString *)sortName
{
    return _nodeName;
}

//-------------------------------------------------------------------------
// NSObject methods
//-------------------------------------------------------------------------

- (NSString *)description
{
    return
        [NSString stringWithFormat:
            @"<%@: nodeName=%@>",
            [self className],
            _nodeName];
}

@end
