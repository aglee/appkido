//
//  AKMemberToken.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKMemberToken.h"
#import "AKBehaviorToken.h"
#import "DIGSLog.h"

@implementation AKMemberToken

@dynamic punctuatedName;

#pragma mark - Getters and setters

- (NSString *)punctuatedName
{
    return self.name;
}

#pragma mark - AKToken methods

- (NSString *)displayName
{
    NSString *displayString = self.punctuatedName;

//    // Qualify the member name with ancestor or protocol info if any.
//    if (_behaviorToken != self.owningBehavior) {
//        if ([self.owningBehavior isClassToken]) {
//            // We inherited this member from an ancestor class.
//            displayString = [NSString stringWithFormat:@"%@ (%@)",
//                             displayString, self.owningBehavior.tokenName];
//        } else {
//            // This member is a method we implement in order to conform to
//            // a protocol.
//            displayString = [NSString stringWithFormat:@"%@ <%@>",
//                             displayString, self.owningBehavior.tokenName];
//        }
//    }
//
//    // If this is a method that is added by a framework that is not the class's
//    // main framework, show that.
//    NSString *memberFrameworkName = self.frameworkName;
//    BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:_behaviorToken.frameworkName];
//
//    if (!memberIsInSameFramework) {
//        displayString = [NSString stringWithFormat:@"%@ [%@]",
//                         displayString, memberFrameworkName];
//    }
//
//    // In the Feb 2007 docs (maybe earlier?), deprecated methods are documented
//    // separately, so it's possible for us to know which methods are deprecated,
//    // assuming the docs are accurate.
//    //
//    // If we know the method is deprecated, show that.
//    if (self.isDeprecated) {
//        displayString = [NSString stringWithFormat:@"%@ (deprecated)", displayString];
//    }
//
//    // All done.
    return displayString;
}

// This implementation of -commentString assumes the receiver represents a
// method.  Subclasses of AKMemberDoc for which this is not true need to
// override this method.
//- (NSString *)commentString
//{
//    NSString *memberFrameworkName = self.token.frameworkName;
//    BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:self.behaviorToken.frameworkName];
//    AKBehaviorToken *owningBehavior = ((AKMemberToken *)self.token).owningBehavior;
//
//    if (self.behaviorToken == owningBehavior) {
//        // We're the first class/protocol to declare this method.
//        if (memberIsInSameFramework) {
//            return @"";
//        } else {
//            return [NSString stringWithFormat:@"This method is added by a category in %@.",
//                    memberFrameworkName];
//        }
//    } else if ([owningBehavior isClassToken]) {
//        // We inherited this method from an ancestor class.
//        if (memberIsInSameFramework) {
//            return [NSString stringWithFormat:@"This method is inherited from class %@.",
//                    owningBehavior.tokenName];
//        } else {
//            return [NSString stringWithFormat:@"This method is inherited from %@ class %@.",
//                    memberFrameworkName, owningBehavior.tokenName];
//        }
//    } else {
//        // We implement this method in order to conform to a protocol.
//        if (memberIsInSameFramework) {
//            return [NSString stringWithFormat:@"This method is declared in protocol <%@>.",
//                    owningBehavior.tokenName];
//        } else {
//            return [NSString stringWithFormat:@"This method is declared in %@ protocol <%@>.",
//                    memberFrameworkName, owningBehavior.tokenName];
//        }
//    }
//}

@end
