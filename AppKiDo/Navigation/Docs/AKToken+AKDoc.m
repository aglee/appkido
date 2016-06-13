//
//  AKToken+AKDoc.m
//  AppKiDo
//
//  Created by Andy Lee on 5/19/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKToken+AKDoc.h"
#import "AKBehaviorToken.h"
#import "AKBindingToken.h"
#import "AKDatabase.h"
#import "AKInstanceMethodToken.h"
#import "AKNotificationToken.h"
#import "AKPropertyToken.h"
#import "DocSetIndex.h"

@implementation AKToken (AKDoc)

- (NSString *)displayNameForDocList
{
	return self.displayName;
}

- (NSString *)commentString
{
	return @"";
}

- (NSURL *)docURLAccordingToDatabase:(AKDatabase *)database
{
	NSURL *baseURL = database.docSetIndex.documentsBaseURL;
	NSString *relativePath = self.tokenMO.metainformation.file.path;
	if (relativePath == nil) {
		return nil;
	}
	NSURL *docURL = [baseURL URLByAppendingPathComponent:relativePath];
	NSString *anchor = self.tokenMO.metainformation.anchor;
	if (anchor) {
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:docURL resolvingAgainstBaseURL:NO];
		urlComponents.fragment = anchor;
		docURL = [urlComponents URL];
	}
	return docURL;
}

@end

#pragma mark -

@implementation AKBehaviorToken (AKDoc)

- (NSString *)displayNameForDocList
{
	return self.tokenMO.parentNode.kName;
}

@end

#pragma mark -

@implementation AKBindingToken (AKDoc)

//#pragma mark - <AKDoc> methods
//
//- (NSString *)commentString
//{
//	NSString *methodFrameworkName = self.token.frameworkName;
//	NSString *behaviorFrameworkName = self.behaviorToken.frameworkName;
//	BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
//	AKBehaviorToken *ownerOfMethod = ((AKMemberToken *)self.token).owningBehavior;
//
//	if (self.behaviorToken == ownerOfMethod) {
//		// We're the first class/protocol to declare this method.
//		if (methodIsInSameFramework) {
//			return @"";
//		} else {
//			return [NSString stringWithFormat: @"This binding comes from the %@ framework.",
//					methodFrameworkName];
//		}
//	} else {
//		// We inherited this method from an ancestor class.
//		if (methodIsInSameFramework) {
//			return [NSString stringWithFormat:@"This binding is exposed by class %@.",
//					ownerOfMethod.tokenName];
//		} else {
//			return [NSString stringWithFormat:@"This binding is exposed by %@ class %@.",
//					methodFrameworkName, ownerOfMethod.tokenName];
//		}
//	}
//}

@end

#pragma mark -

@implementation AKInstanceMethodToken (AKDoc)

//#pragma mark - <AKDoc> methods
//
//- (NSString *)commentString
//{
//	NSString *methodFrameworkName = self.token.frameworkName;
//	NSString *behaviorFrameworkName = self.behaviorToken.frameworkName;
//	BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
//	AKBehaviorToken *ownerOfMethod = ((AKMemberToken *)self.token).owningBehavior;
//
//	if (self.behaviorToken == ownerOfMethod) {
//		// We're the first class/protocol to declare this method.
//		if (methodIsInSameFramework) {
//			return @"";
//		} else {
//			return [NSString stringWithFormat:@"This delegate method comes from the %@ framework.", methodFrameworkName];
//		}
//	} else if ([ownerOfMethod isClassToken]) {
//		// We inherited this method from an ancestor class.
//		if (methodIsInSameFramework) {
//			return [NSString stringWithFormat:@"This delegate method is used by class %@.", ownerOfMethod.tokenName];
//		} else {
//			return
//			[NSString stringWithFormat:
//			 @"This delegate method is used by %@ class %@.", methodFrameworkName, ownerOfMethod.tokenName];
//		}
//	} else {
//		// This method is declared in a formal protocol.
//		if (methodIsInSameFramework) {
//			return [NSString stringWithFormat:@"This delegate method is declared in protocol %@.", ownerOfMethod.tokenName];
//		} else {
//			return
//			[NSString stringWithFormat:
//			 @"This delegate method is declared in %@ protocol %@.", methodFrameworkName, ownerOfMethod.tokenName];
//		}
//	}
//}
//

@end

#pragma mark -

@implementation AKMemberToken (AKDoc)

- (NSString *)displayNameForDocList
{
	NSString *displayName = [super displayNameForDocList];
	if (self.owningBehavior.isDelegateProtocolToken) {
		displayName = [NSString stringWithFormat:@"%@ <%@>", displayName, self.owningBehavior.name];
	}
	return displayName;
}

// This implementation of -commentString assumes the receiver represents a
// method.  Subclasses of AKMemberDoc for which this is not true need to
// override this method.
//- (NSString *)commentString
//{
//	NSString *memberFrameworkName = self.token.frameworkName;
//	BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:self.behaviorToken.frameworkName];
//	AKBehaviorToken *owningBehavior = ((AKMemberToken *)self.token).owningBehavior;
//
//	if (self.behaviorToken == owningBehavior) {
//		// We're the first class/protocol to declare this method.
//		if (memberIsInSameFramework) {
//			return @"";
//		} else {
//			return [NSString stringWithFormat:@"This method is added by a category in %@.",
//					memberFrameworkName];
//		}
//	} else if ([owningBehavior isClassToken]) {
//		// We inherited this method from an ancestor class.
//		if (memberIsInSameFramework) {
//			return [NSString stringWithFormat:@"This method is inherited from class %@.",
//					owningBehavior.tokenName];
//		} else {
//			return [NSString stringWithFormat:@"This method is inherited from %@ class %@.",
//					memberFrameworkName, owningBehavior.tokenName];
//		}
//	} else {
//		// We implement this method in order to conform to a protocol.
//		if (memberIsInSameFramework) {
//			return [NSString stringWithFormat:@"This method is declared in protocol <%@>.",
//					owningBehavior.tokenName];
//		} else {
//			return [NSString stringWithFormat:@"This method is declared in %@ protocol <%@>.",
//					memberFrameworkName, owningBehavior.tokenName];
//		}
//	}
//}

@end

#pragma mark -

@implementation AKNotificationToken (AKDoc)

//#pragma mark - <AKDoc> methods
//
//- (NSString *)commentString
//{
//	NSString *methodFrameworkName = self.token.frameworkName;
//	NSString *behaviorFrameworkName = self.behaviorToken.frameworkName;
//	BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
//	AKBehaviorToken *ownerOfMethod = ((AKMemberToken *)self.token).owningBehavior;
//
//	if (self.behaviorToken == ownerOfMethod) {
//		// We're the first class/protocol to declare this method.
//		if (methodIsInSameFramework) {
//			return @"";
//		} else {
//			return [NSString stringWithFormat: @"This notification comes from the %@ framework.",
//					methodFrameworkName];
//		}
//	} else {
//		// We inherited this method from an ancestor class.
//		if (methodIsInSameFramework) {
//			return [NSString stringWithFormat:@"This notification is delivered by class %@.",
//					ownerOfMethod.tokenName];
//		} else {
//			return [NSString stringWithFormat:@"This notification is delivered by %@ class %@.",
//					methodFrameworkName, ownerOfMethod.tokenName];
//		}
//	}
//}

@end

#pragma mark -

@implementation AKPropertyToken (AKDoc)

//- (NSString *)commentString
//{
//	NSString *methodFrameworkName = self.token.frameworkName;
//	NSString *behaviorFrameworkName = self.behaviorToken.frameworkName;
//	BOOL methodIsInSameFramework = [methodFrameworkName isEqualToString:behaviorFrameworkName];
//	AKBehaviorToken *ownerOfMethod = self.owningBehavior;
//
//	if (self.behaviorToken == ownerOfMethod) {
//		// We're the first class/protocol to declare this property.
//		if (methodIsInSameFramework) {
//			return @"";
//		} else {
//			return [NSString stringWithFormat:@"This property comes from the %@ framework.",
//					methodFrameworkName];
//		}
//	} else {
//		// We inherited this property from an ancestor class or protocol.
//		if (methodIsInSameFramework) {
//			if ([ownerOfMethod isClassToken]) {
//				return [NSString stringWithFormat:@"This property is inherited from class %@.",
//						ownerOfMethod.tokenName];
//			} else {
//				return [NSString stringWithFormat:@"This property is declared in protocol <%@>.", ownerOfMethod.tokenName];
//			}
//		} else {
//			if ([ownerOfMethod isClassToken]) {
//				return [NSString stringWithFormat:@"This property is inherited from %@ class %@.",
//						methodFrameworkName, ownerOfMethod.tokenName];
//			} else {
//				return [NSString stringWithFormat:@"This property is declared in %@ protocol <%@>.",
//						methodFrameworkName, ownerOfMethod.tokenName];
//			}
//		}
//	}
//}

@end
