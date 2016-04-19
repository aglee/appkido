//
//  AKMemberNode.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKMemberNode.h"

#import "DIGSLog.h"
#import "AKBehaviorNode.h"

@implementation AKMemberNode

@synthesize owningBehavior = _owningBehavior;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName owningBehavior:(AKBehaviorNode *)behaviorNode
{
    if ((self = [super initWithNodeName:nodeName database:database frameworkName:frameworkName]))
    {
        _owningBehavior = behaviorNode;
    }

    return self;
}

- (instancetype)initWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithNodeName:nil database:nil frameworkName:nil owningBehavior:nil];
}

@end
