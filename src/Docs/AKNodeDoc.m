//
//  AKNodeDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKNodeDoc.h"

#import "AKTokenItem.h"

@implementation AKNodeDoc

@synthesize tokenItem = _tokenItem;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNode:(AKTokenItem *)tokenItem
{
    if ((self = [super init]))
    {
        _tokenItem = tokenItem;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithNode:nil];
}


#pragma mark -
#pragma mark AKDoc methods

- (AKFileSection *)fileSection
{
    return _tokenItem.nodeDocumentation;
}

- (NSString *)docName
{
    return _tokenItem.nodeName;
}

@end
