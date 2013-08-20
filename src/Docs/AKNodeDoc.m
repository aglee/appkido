//
//  AKNodeDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKNodeDoc.h"

#import "AKDatabaseNode.h"

@implementation AKNodeDoc

@synthesize databaseNode = _databaseNode;

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNode:(AKDatabaseNode *)databaseNode
{
    if ((self = [super init]))
    {
        _databaseNode = [databaseNode retain];
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
    [_databaseNode release];

    [super dealloc];
}

#pragma mark -
#pragma mark AKDoc methods

- (AKFileSection *)fileSection
{
    return [_databaseNode nodeDocumentation];
}

- (NSString *)docName
{
    return [_databaseNode nodeName];
}

@end
