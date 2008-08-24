//
//  AKNodeDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKNodeDoc.h"

#import "DIGSLog.h"
#import "AKDatabaseNode.h"

@implementation AKNodeDoc

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

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
    DIGSLogNondesignatedInitializer();
    [self dealloc];
    return nil;
}

- (void)dealloc
{
    [_databaseNode release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKDoc methods
//-------------------------------------------------------------------------

- (AKFileSection *)fileSection
{
    return [_databaseNode nodeDocumentation];
}

- (NSString *)docName
{
    return [_databaseNode nodeName];
}

@end
