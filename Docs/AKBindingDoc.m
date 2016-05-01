//
//  AKBindingDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 5/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKBindingDoc.h"
#import "AKBehaviorItem.h"
#import "AKMethodItem.h"

@implementation AKBindingDoc

#pragma mark - AKDoc methods

- (NSString *)commentString
{
    NSString *methodFrameworkName = self.tokenItem.frameworkName;
    NSString *behaviorFrameworkName = self.behaviorItem.frameworkName;
    BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
    AKBehaviorItem *ownerOfMethod = ((AKMemberItem *)self.tokenItem).owningBehavior;

    if (self.behaviorItem == ownerOfMethod) {
        // We're the first class/protocol to declare this method.
        if (methodIsInSameFramework) {
            return @"";
        } else {
            return [NSString stringWithFormat: @"This binding comes from the %@ framework.",
                    methodFrameworkName];
        }
    } else {
        // We inherited this method from an ancestor class.
        if (methodIsInSameFramework) {
            return [NSString stringWithFormat:@"This binding is exposed by class %@.",
                    ownerOfMethod.tokenName];
        } else {
            return [NSString stringWithFormat:@"This binding is exposed by %@ class %@.",
                    methodFrameworkName, ownerOfMethod.tokenName];
        }
    }
}

@end
