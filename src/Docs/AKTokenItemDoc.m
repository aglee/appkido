//
//  AKTokenItemDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKTokenItemDoc.h"

#import "AKTokenItem.h"

@implementation AKTokenItemDoc

@synthesize tokenItem = _tokenItem;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithTokenItem:(AKTokenItem *)tokenItem
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
    return [self initWithTokenItem:nil];
}


#pragma mark -
#pragma mark AKDoc methods

- (AKFileSection *)fileSection
{
    return _tokenItem.tokenItemDocumentation;
}

- (NSString *)docName
{
    return _tokenItem.tokenName;
}

@end
