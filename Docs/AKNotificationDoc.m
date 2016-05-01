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

#pragma mark - AKMemberDoc methods

+ (NSString *)punctuateTokenName:(NSString *)methodName
{
    return methodName;
}

#pragma mark - AKDoc methods

- (NSString *)commentString
{
    NSString *methodFrameworkName = self.memberItem.frameworkName;
    NSString *behaviorFrameworkName = self.behaviorItem.frameworkName;
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
                    ownerOfMethod.tokenName];
        }
        else
        {
            return [NSString stringWithFormat:@"This notification is delivered by %@ class %@.",
                    methodFrameworkName, ownerOfMethod.tokenName];
        }
    }
}

@end
