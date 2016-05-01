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
#pragma mark Init/awake/dealloc

- (instancetype)initWithTokenName:(NSString *)tokenName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    if ((self = [super init]))
    {
        _tokenName = [tokenName copy];
        _owningDatabase = database;
        _nameOfOwningFramework = [frameworkName copy];
        _tokenItemDocumentation = nil;
        _isDeprecated = NO;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithTokenName:nil database:nil frameworkName:nil];
}


#pragma mark -
#pragma mark AKSortable methods

- (NSString *)sortName
{
    return _tokenName;
}

#pragma mark -
#pragma mark NSObject methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: tokenName=%@>", self.className, _tokenName];
}

@end
