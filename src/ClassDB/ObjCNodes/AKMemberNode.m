//
//  AKMemberNode.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKMemberNode.h"

#import "DIGSLog.h"
#import "AKBehaviorItem.h"

@implementation AKMemberNode

@synthesize owningBehavior = _owningBehavior;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName owningBehavior:(AKBehaviorItem *)behaviorItem
{
    if ((self = [super initWithNodeName:nodeName database:database frameworkName:frameworkName]))
    {
        _owningBehavior = behaviorItem;
    }

    return self;
}

- (instancetype)initWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithNodeName:nil database:nil frameworkName:nil owningBehavior:nil];
}

@end
