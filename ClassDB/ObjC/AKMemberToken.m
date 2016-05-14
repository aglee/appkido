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

- (instancetype)initWithName:(NSString *)name owningBehavior:(AKBehaviorToken *)behaviorToken
{
    NSParameterAssert(behaviorToken != nil);
    self = [super initWithName:name];
    if (self) {
        _owningBehavior = behaviorToken;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:nil owningBehavior:nil];
}

@end
