//
//  AKPropertyDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 7/25/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKPropertyDoc.h"
#import "AKBehaviorToken.h"
#import "AKMethodItem.h"

@implementation AKPropertyDoc

#pragma mark - AKMemberDoc methods

+ (NSString *)punctuateTokenName:(NSString *)tokenName
{
	return [@"." stringByAppendingString:tokenName];
}

#pragma mark - AKDoc methods

- (NSString *)commentString
{
	NSString *methodFrameworkName = self.token.frameworkName;
	NSString *behaviorFrameworkName = self.behaviorToken.frameworkName;
	BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
	AKBehaviorToken *ownerOfMethod = ((AKMethodItem *)self.token).owningBehavior;

	if (self.behaviorToken == ownerOfMethod) {
		// We're the first class/protocol to declare this property.
		if (methodIsInSameFramework) {
			return @"";
		} else {
			return [NSString stringWithFormat:@"This property comes from the %@ framework.",
					methodFrameworkName];
		}
	} else {
		// We inherited this property from an ancestor class or protocol.
		if (methodIsInSameFramework) {
			if ([ownerOfMethod isClassToken]) {
				return [NSString stringWithFormat:@"This property is inherited from class %@.",
						ownerOfMethod.tokenName];
			} else {
				return [NSString stringWithFormat:@"This property is declared in protocol <%@>.", ownerOfMethod.tokenName];
			}
		} else {
			if ([ownerOfMethod isClassToken]) {
				return [NSString stringWithFormat:@"This property is inherited from %@ class %@.",
						methodFrameworkName, ownerOfMethod.tokenName];
			} else {
				return [NSString stringWithFormat:@"This property is declared in %@ protocol <%@>.",
						methodFrameworkName, ownerOfMethod.tokenName];
			}
		}
	}
}

@end
