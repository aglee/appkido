//
// AKMethodItem.m
//
// Created by Andy Lee on Thu Jun 27 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKMethodItem.h"

#import "AKClassToken.h"

@implementation AKMethodItem

#pragma mark - Init/awake/dealloc

- (instancetype)initWithToken:(DSAToken *)token owningBehavior:(AKBehaviorToken *)behaviorToken
{
    self = [super initWithToken:token owningBehavior:behaviorToken];
    if (self) {
        _argumentTypes = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark - Getters and setters

- (BOOL)isClassMethod
{
    return ([(AKClassToken *)self.owningBehavior classMethodWithName:self.tokenName] != nil);
}

- (BOOL)isDelegateMethod
{
    return ([self.owningBehavior isClassToken]
            && ([(AKClassToken *)self.owningBehavior delegateMethodWithName:self.tokenName] != nil));
}

- (NSArray *)argumentTypes
{
    return _argumentTypes;
}

- (void)setArgumentTypes:(NSArray *)argTypes
{
    [_argumentTypes removeAllObjects];
    [_argumentTypes addObjectsFromArray:argTypes];
}

@end
