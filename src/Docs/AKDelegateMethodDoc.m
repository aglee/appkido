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
    AKFramework *methodFramework = [_memberNode owningFramework];
    BOOL methodIsInSameFramework = [methodFramework isEqual:[_behaviorNode owningFramework]];
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
            return [NSString stringWithFormat:@"This delegate method comes from the %@ framework.", methodFramework];
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
                    @"This delegate method is used by %@ class %@.", methodFramework, [ownerOfMethod nodeName]];
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
                    @"This delegate method is declared in %@ protocol %@.", methodFramework, [ownerOfMethod nodeName]];
        }
    }
}

@end
