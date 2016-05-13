//
//  AKMemberToken.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKMemberToken.h"
#import "AKBehaviorToken.h"
#import "DIGSLog.h"

@implementation AKMemberToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO owningBehavior:(AKBehaviorToken *)behaviorToken
{
    NSParameterAssert(behaviorToken != nil);
    self = [super initWithTokenMO:tokenMO];
    if (self) {
        _owningBehavior = behaviorToken;
    }
    return self;
}

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithTokenMO:nil owningBehavior:nil];
}

@end
