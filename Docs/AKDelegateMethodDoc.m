/*
 * AKDelegateMethodDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDelegateMethodDoc.h"
#import "AKBehaviorToken.h"
#import "AKMethodToken.h"

@implementation AKDelegateMethodDoc

#pragma mark - AKMemberDoc methods

+ (NSString *)punctuateTokenName:(NSString *)tokenName
{
	return [@"-" stringByAppendingString:tokenName];
}

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
			return [NSString stringWithFormat:@"This delegate method comes from the %@ framework.", methodFrameworkName];
		}
	} else if ([ownerOfMethod isClassToken]) {
		// We inherited this method from an ancestor class.
		if (methodIsInSameFramework) {
			return [NSString stringWithFormat:@"This delegate method is used by class %@.", ownerOfMethod.tokenName];
		} else {
			return
			[NSString stringWithFormat:
			 @"This delegate method is used by %@ class %@.", methodFrameworkName, ownerOfMethod.tokenName];
		}
	} else {
		// This method is declared in a formal protocol.
		if (methodIsInSameFramework) {
			return [NSString stringWithFormat:@"This delegate method is declared in protocol %@.", ownerOfMethod.tokenName];
		} else {
			return
			[NSString stringWithFormat:
			 @"This delegate method is declared in %@ protocol %@.", methodFrameworkName, ownerOfMethod.tokenName];
		}
	}
}

@end
