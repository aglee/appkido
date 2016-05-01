//
//  AKPropertyDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 7/25/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKPropertyDoc.h"

#import "AKBehaviorItem.h"
#import "AKMethodItem.h"

@implementation AKPropertyDoc

#pragma mark -
#pragma mark AKMemberDoc methods

+ (NSString *)punctuateTokenName:(NSString *)methodName
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
        // We're the first class/protocol to declare this property.
        if (methodIsInSameFramework)
        {
            return @"";
        }
        else
        {
            return [NSString stringWithFormat:@"This property comes from the %@ framework.",
                    methodFrameworkName];
        }
    }
    else
    {
        // We inherited this property from an ancestor class or protocol.
        if (methodIsInSameFramework)
        {
            if ([ownerOfMethod isClassItem])
            {
                return [NSString stringWithFormat:@"This property is inherited from class %@.",
                        ownerOfMethod.tokenName];
            }
            else
            {
                return [NSString stringWithFormat:@"This property is declared in protocol <%@>.", ownerOfMethod.tokenName];
            }
        }
        else
        {
            if ([ownerOfMethod isClassItem])
            {
                return [NSString stringWithFormat:@"This property is inherited from %@ class %@.",
                        methodFrameworkName, ownerOfMethod.tokenName];
            }
            else
            {
                return [NSString stringWithFormat:@"This property is declared in %@ protocol <%@>.",
                        methodFrameworkName, ownerOfMethod.tokenName];
            }
        }
    }
}

@end