/*
 * AKNotificationDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNotificationDoc.h"

#import "AKBehaviorItem.h"
#import "AKMethodItem.h"

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
    NSString *methodFrameworkName = self.memberItem.nameOfOwningFramework;
    NSString *behaviorFrameworkName = self.behaviorItem.nameOfOwningFramework;
    BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
    AKBehaviorItem *ownerOfMethod = self.memberItem.owningBehavior;

    if (self.behaviorItem == ownerOfMethod)
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
                    ownerOfMethod.nodeName];
        }
        else
        {
            return [NSString stringWithFormat:@"This notification is delivered by %@ class %@.",
                    methodFrameworkName, ownerOfMethod.nodeName];
        }
    }
}

@end
