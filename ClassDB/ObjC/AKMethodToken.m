//
// AKMethodToken.m
//
// Created by Andy Lee on Thu Jun 27 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKMethodToken.h"
#import "AKClassToken.h"

@implementation AKMethodToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name owningBehavior:(AKBehaviorToken *)behaviorToken
{
    self = [super initWithName:name owningBehavior:behaviorToken];
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
