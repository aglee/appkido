//
//  AKMemberItem.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKMemberItem.h"

#import "DIGSLog.h"
#import "AKBehaviorToken.h"

@implementation AKMemberItem

#pragma mark - Init/awake/dealloc

- (instancetype)initWithToken:(DSAToken *)token owningBehavior:(AKBehaviorToken *)behaviorToken
{
    NSParameterAssert(behaviorToken != nil);
    self = [super initWithToken:token];
    if (self) {
        _owningBehavior = behaviorToken;
    }
    return self;
}

- (instancetype)initWithToken:(DSAToken *)token
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithToken:nil owningBehavior:nil];
}

@end
