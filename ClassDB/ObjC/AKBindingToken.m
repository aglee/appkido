//
//  AKBindingToken.m
//  AppKiDo
//
//  Created by Andy Lee on 5/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKBindingToken.h"

@implementation AKBindingToken

//#pragma mark - AKDoc methods
//
//- (NSString *)commentString
//{
//    NSString *methodFrameworkName = self.token.frameworkName;
//    NSString *behaviorFrameworkName = self.behaviorToken.frameworkName;
//    BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
//    AKBehaviorToken *ownerOfMethod = ((AKMemberToken *)self.token).owningBehavior;
//
//    if (self.behaviorToken == ownerOfMethod) {
//        // We're the first class/protocol to declare this method.
//        if (methodIsInSameFramework) {
//            return @"";
//        } else {
//            return [NSString stringWithFormat: @"This binding comes from the %@ framework.",
//                    methodFrameworkName];
//        }
//    } else {
//        // We inherited this method from an ancestor class.
//        if (methodIsInSameFramework) {
//            return [NSString stringWithFormat:@"This binding is exposed by class %@.",
//                    ownerOfMethod.tokenName];
//        } else {
//            return [NSString stringWithFormat:@"This binding is exposed by %@ class %@.",
//                    methodFrameworkName, ownerOfMethod.tokenName];
//        }
//    }
//}

@end