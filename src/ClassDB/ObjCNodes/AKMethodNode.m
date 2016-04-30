//
// AKMethodNode.m
//
// Created by Andy Lee on Thu Jun 27 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKMethodNode.h"

#import "AKClassNode.h"

@implementation AKMethodNode

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
        owningBehavior:(AKBehaviorItem *)behaviorItem
{
    if ((self = [super initWithNodeName:nodeName
                               database:database
                          frameworkName:frameworkName
                         owningBehavior:behaviorItem]))
    {
        _argumentTypes = [[NSMutableArray alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Getters and setters

- (BOOL)isClassMethod
{
    return ([(AKClassNode *)self.owningBehavior classMethodWithName:self.nodeName] != nil);
}

- (BOOL)isDelegateMethod
{
    return ([self.owningBehavior isClassNode]
            && ([(AKClassNode *)self.owningBehavior delegateMethodWithName:self.nodeName] != nil));
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
