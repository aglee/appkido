//
// AKMethodNode.m
//
// Created by Andy Lee on Thu Jun 27 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKMethodNode.h"

#import "AKClassNode.h"

@implementation AKMethodNode
{
@private
    NSMutableArray *_argumentTypes;
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(AKFramework *)theFramework
    owningBehavior:(AKBehaviorNode *)behaviorNode
{
    if ((self = [super initWithNodeName:nodeName owningFramework:theFramework owningBehavior:behaviorNode]))
    {
        _argumentTypes = [[NSMutableArray alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Getters and setters

- (BOOL)isClassMethod
{
    return ([(AKClassNode *)[self owningBehavior] classMethodWithName:[self nodeName]] != nil);
}

- (BOOL)isDelegateMethod
{
    return ([[self owningBehavior] isClassNode]
            && ([(AKClassNode *)[self owningBehavior] delegateMethodWithName:[self nodeName]] != nil));
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
