/*
 * AKMemberDoc.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKMemberDoc.h"
#import "DIGSLog.h"
#import "AKFrameworkConstants.h"
#import "AKProtocolToken.h"
#import "AKMemberItem.h"

@implementation AKMemberDoc

#pragma mark - Init/awake/dealloc

- (instancetype)initWithMemberItem:(AKMemberItem *)memberItem behaviorToken:(AKBehaviorToken *)behaviorToken
{
	self = [super initWithToken:memberItem];
	if (self) {
		_behaviorToken = behaviorToken;
	}
	return self;
}

- (instancetype)initWithToken:(AKToken *)token
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithMemberItem:nil behaviorToken:nil];
}

#pragma mark - Manipulating token names

+ (NSString *)punctuateTokenName:(NSString *)tokenName
{
	return tokenName;
}

#pragma mark - AKDoc methods

- (NSString *)stringToDisplayInDocList
{
	NSString *displayString = [[self class] punctuateTokenName:self.token.tokenName];
	AKBehaviorToken *owningBehavior = ((AKMemberItem *)self.token).owningBehavior;

	// Qualify the member name with ancestor or protocol info if any.
	if (_behaviorToken != owningBehavior) {
		if ([owningBehavior isClassToken]) {
			// We inherited this member from an ancestor class.
			displayString = [NSString stringWithFormat:@"%@ (%@)",
							 displayString, owningBehavior.tokenName];
		} else {
			// This member is a method we implement in order to conform to
			// a protocol.
			displayString = [NSString stringWithFormat:@"%@ <%@>",
							 displayString, owningBehavior.tokenName];
		}
	}

	// If this is a method that is added by a framework that is not the class's
	// main framework, show that.
	NSString *memberFrameworkName = self.token.frameworkName;
	BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:self.behaviorToken.frameworkName];

	if (!memberIsInSameFramework) {
		displayString = [NSString stringWithFormat:@"%@ [%@]",
						 displayString, memberFrameworkName];
	}

	// In the Feb 2007 docs (maybe earlier?), deprecated methods are documented
	// separately, so it's possible for us to know which methods are deprecated,
	// assuming the docs are accurate.
	//
	// If we know the method is deprecated, show that.
	if (self.token.isDeprecated) {
		displayString = [NSString stringWithFormat:@"%@ (deprecated)", displayString];
	}

	// All done.
	return displayString;
}

// This implementation of -commentString assumes the receiver represents a
// method.  Subclasses of AKMemberDoc for which this is not true need to
// override this method.
- (NSString *)commentString
{
	NSString *memberFrameworkName = self.token.frameworkName;
	BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:self.behaviorToken.frameworkName];
	AKBehaviorToken *owningBehavior = ((AKMemberItem *)self.token).owningBehavior;

	if (self.behaviorToken == owningBehavior) {
		// We're the first class/protocol to declare this method.
		if (memberIsInSameFramework) {
			return @"";
		} else {
			return [NSString stringWithFormat:@"This method is added by a category in %@.",
					memberFrameworkName];
		}
	} else if ([owningBehavior isClassToken]) {
		// We inherited this method from an ancestor class.
		if (memberIsInSameFramework) {
			return [NSString stringWithFormat:@"This method is inherited from class %@.",
					owningBehavior.tokenName];
		} else {
			return [NSString stringWithFormat:@"This method is inherited from %@ class %@.",
					memberFrameworkName, owningBehavior.tokenName];
		}
	} else {
		// We implement this method in order to conform to a protocol.
		if (memberIsInSameFramework) {
			return [NSString stringWithFormat:@"This method is declared in protocol <%@>.",
					owningBehavior.tokenName];
		} else {
			return [NSString stringWithFormat:@"This method is declared in %@ protocol <%@>.",
					memberFrameworkName, owningBehavior.tokenName];
		}
	}
}

@end
