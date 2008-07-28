//
//  AKPropertyDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 7/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKPropertyDoc.h"

#import "AKMethodNode.h"

@implementation AKPropertyDoc

//-------------------------------------------------------------------------
// AKMemberDoc methods
//-------------------------------------------------------------------------

+ (NSString *)punctuateNodeName:(NSString *)methodName
{
    return methodName;
}

//-------------------------------------------------------------------------
// AKDoc methods
//-------------------------------------------------------------------------

- (NSString *)commentString
{
    NSString *methodFrameworkName = [_memberNode owningFramework];
    BOOL methodIsInSameFramework = 
        [methodFrameworkName
            isEqualToString:[_behaviorNode owningFramework]];
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
            return
                [NSString
                    stringWithFormat:
                        @"This property comes from the %@ framework.",
                        methodFrameworkName];
        }
    }
    else
    {
        // We inherited this property from an ancestor class.
        if (methodIsInSameFramework)
        {
            return
                [NSString stringWithFormat:
                    @"This property is inherited from class %@.",
                    [ownerOfMethod nodeName]];
        }
        else
        {
            return
                [NSString stringWithFormat:
                    @"This property is inherited from %@ class %@.",
                    methodFrameworkName,
                    [ownerOfMethod nodeName]];
        }
    }
}

@end
