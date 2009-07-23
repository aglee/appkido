//
//  AKPropertyDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 7/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKPropertyDoc.h"

#import "AKBehaviorNode.h"
#import "AKMethodNode.h"

@implementation AKPropertyDoc


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
    AKFramework *methodFrameworkName = [_memberNode owningFramework];
    BOOL methodIsInSameFramework = [methodFrameworkName isEqual:[_behaviorNode owningFramework]];
    AKBehaviorNode *ownerOfMethod = [_memberNode owningBehavior];

    if (_behaviorNode == ownerOfMethod)
    {
        // We're the first class/protocol to declare this property.
        if (methodIsInSameFramework)
        {
            return @"";
        }
        else
        {
            return [NSString stringWithFormat:@"This property comes from the %@ framework.", methodFrameworkName];
        }
    }
    else
    {
        // We inherited this property from an ancestor class or protocol.
        if (methodIsInSameFramework)
        {
            if ([ownerOfMethod isClassNode])
            {
                return [NSString stringWithFormat:@"This property is inherited from class %@.", [ownerOfMethod nodeName]];
            }
            else
            {
                return [NSString stringWithFormat:@"This property is declared in protocol <%@>.", [ownerOfMethod nodeName]];
            }
        }
        else
        {
            if ([ownerOfMethod isClassNode])
            {
                return
                    [NSString stringWithFormat:
                        @"This property is inherited from @% class %@.", methodFrameworkName, [ownerOfMethod nodeName]];
            }
            else
            {
                return
                    [NSString stringWithFormat:
                        @"This property is declared in %@ protocol <%@>.", methodFrameworkName, [ownerOfMethod nodeName]];
            }
        }
    }
}

@end
