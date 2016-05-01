/*
 * AKDelegateMethodDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDelegateMethodDoc.h"

#import "AKBehaviorItem.h"
#import "AKMethodItem.h"

@implementation AKDelegateMethodDoc

#pragma mark -
#pragma mark AKMemberDoc methods

+ (NSString *)punctuateTokenName:(NSString *)methodName
{
    return [@"-" stringByAppendingString:methodName];
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
            return [NSString stringWithFormat:@"This delegate method comes from the %@ framework.", methodFrameworkName];
        }
    }
    else if ([ownerOfMethod isClassItem])
    {
        // We inherited this method from an ancestor class.
        if (methodIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This delegate method is used by class %@.", ownerOfMethod.tokenName];
        }
        else
        {
            return
                [NSString stringWithFormat:
                    @"This delegate method is used by %@ class %@.", methodFrameworkName, ownerOfMethod.tokenName];
        }
    }
    else
    {
        // This method is declared in a formal protocol.
        if (methodIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This delegate method is declared in protocol %@.", ownerOfMethod.tokenName];
        }
        else
        {
            return
                [NSString stringWithFormat:
                    @"This delegate method is declared in %@ protocol %@.", methodFrameworkName, ownerOfMethod.tokenName];
        }
    }
}

@end