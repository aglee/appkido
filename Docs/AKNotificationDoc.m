/*
 * AKNotificationDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNotificationDoc.h"
#import "AKBehaviorToken.h"
#import "AKMethodToken.h"

@implementation AKNotificationDoc

#pragma mark - AKDoc methods

- (NSString *)commentString
{
	NSString *methodFrameworkName = self.token.frameworkName;
	NSString *behaviorFrameworkName = self.behaviorToken.frameworkName;
	BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
	AKBehaviorToken *ownerOfMethod = ((AKMemberToken *)self.token).owningBehavior;

	if (self.behaviorToken == ownerOfMethod) {
		// We're the first class/protocol to declare this method.
		if (methodIsInSameFramework) {
			return @"";
		} else {
			return [NSString stringWithFormat: @"This notification comes from the %@ framework.",
					methodFrameworkName];
		}
	} else {
		// We inherited this method from an ancestor class.
		if (methodIsInSameFramework) {
			return [NSString stringWithFormat:@"This notification is delivered by class %@.",
					ownerOfMethod.tokenName];
		} else {
			return [NSString stringWithFormat:@"This notification is delivered by %@ class %@.",
					methodFrameworkName, ownerOfMethod.tokenName];
		}
	}
}

@end
