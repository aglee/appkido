/*
 * AKNotificationDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNotificationDoc.h"

#import "AKBehaviorNode.h"
#import "AKMethodNode.h"

@implementation AKNotificationDoc


#pragma mark -
#pragma mark AKMemberDoc methods

+ (NSString *)punctuateNodeName:(NSString *)methodName
{
    return methodName;
}


#pragma mark -
#pragma mark AKDoc methods

- (NSString *)commentString
{
    NSString *methodFrameworkName = [_memberNode owningFrameworkName];
    BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:[_behaviorNode owningFrameworkName]];
    AKBehaviorNode *ownerOfMethod = [_memberNode owningBehavior];

    if (_behaviorNode == ownerOfMethod)
    {
        // We're the first class/protocol to declare this method.
        if (methodIsInSameFramework)
        {
            return @"";
        }
        else
        {
            return [NSString stringWithFormat: @"This notification comes from the %@ framework.",
                    methodFrameworkName];
        }
    }
    else
    {
        // We inherited this method from an ancestor class.
        if (methodIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This notification is delivered by class %@.",
                    [ownerOfMethod nodeName]];
        }
        else
        {
            return [NSString stringWithFormat:@"This notification is delivered by %@ class %@.",
                    methodFrameworkName, [ownerOfMethod nodeName]];
        }
    }
}


@end
