//
//  AKNotificationToken.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKNotificationToken.h"

@implementation AKNotificationToken

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
//            return [NSString stringWithFormat: @"This notification comes from the %@ framework.",
//                    methodFrameworkName];
//        }
//    } else {
//        // We inherited this method from an ancestor class.
//        if (methodIsInSameFramework) {
//            return [NSString stringWithFormat:@"This notification is delivered by class %@.",
//                    ownerOfMethod.tokenName];
//        } else {
//            return [NSString stringWithFormat:@"This notification is delivered by %@ class %@.",
//                    methodFrameworkName, ownerOfMethod.tokenName];
//        }
//    }
//}

@end
