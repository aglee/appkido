//
//  AKMemberItem.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKMemberItem.h"

#import "DIGSLog.h"
#import "AKBehaviorItem.h"

@implementation AKMemberItem

@synthesize owningBehavior = _owningBehavior;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenName:(NSString *)tokenName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName owningBehavior:(AKBehaviorItem *)behaviorItem
{
    if ((self = [super initWithTokenName:tokenName database:database frameworkName:frameworkName]))
    {
        _owningBehavior = behaviorItem;
    }

    return self;
}

- (instancetype)initWithTokenName:(NSString *)tokenName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithTokenName:nil database:nil frameworkName:nil owningBehavior:nil];
}

@end
