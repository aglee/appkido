/*
 * AKDelegateMethodDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDelegateMethodDoc.h"

#import "AKBehaviorNode.h"
#import "AKMethodNode.h"

@implementation AKDelegateMethodDoc

#pragma mark -
#pragma mark AKMemberDoc methods

+ (NSString *)punctuateNodeName:(NSString *)methodName
{
    return [@"-" stringByAppendingString:methodName];
}

#pragma mark -
#pragma mark AKDoc methods

- (NSString *)commentString
{
    NSString *methodFrameworkName = [[self memberNode] nameOfOwningFramework];
    NSString *behaviorFrameworkName = [[self behaviorNode] nameOfOwningFramework];
    BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
    AKBehaviorNode *ownerOfMethod = [[self memberNode] owningBehavior];

    if ([self behaviorNode] == ownerOfMethod)
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
    else if ([ownerOfMethod isClassNode])
    {
        // We inherited this method from an ancestor class.
        if (methodIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This delegate method is used by class %@.", [ownerOfMethod nodeName]];
        }
        else
        {
            return
                [NSString stringWithFormat:
                    @"This delegate method is used by %@ class %@.", methodFrameworkName, [ownerOfMethod nodeName]];
        }
    }
    else
    {
        // This method is declared in a formal protocol.
        if (methodIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This delegate method is declared in protocol %@.", [ownerOfMethod nodeName]];
        }
        else
        {
            return
                [NSString stringWithFormat:
                    @"This delegate method is declared in %@ protocol %@.", methodFrameworkName, [ownerOfMethod nodeName]];
        }
    }
}

@end
