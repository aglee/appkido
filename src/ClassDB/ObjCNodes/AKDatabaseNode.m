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

#pragma mark -
#pragma mark Factory methods

+ (id)nodeWithNodeName:(NSString *)nodeName owningFramework:(AKFramework *)aFramework
{
    return [[self alloc] initWithNodeName:nodeName owningFramework:aFramework];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName owningFramework:(AKFramework *)aFramework
{
    if ((self = [super init]))
    {
        _nodeName = nodeName;
        _owningFramework = aFramework;
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
#pragma mark Getters and setters

- (NSString *)nodeName
{
    return _nodeName;
}

- (AKFramework *)owningFramework
{
    return _owningFramework;
}

- (void)setOwningFramework:(AKFramework *)aFramework
{
    _owningFramework = aFramework;
}

- (AKFileSection *)nodeDocumentation
{
    return _nodeDocumentation;
}

- (void)setNodeDocumentation:(AKFileSection *)fileSection
{
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
