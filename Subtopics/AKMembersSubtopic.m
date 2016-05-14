/*
 * AKMembersSubtopic.m
 *
 * Created by Andy Lee on Tue Jul 09 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKMembersSubtopic.h"
#import "DIGSLog.h"
#import "AKClassToken.h"
#import "AKProtocolToken.h"
#import "AKMethodToken.h"

@implementation AKMembersSubtopic

#pragma mark - Init/awake/dealloc

- (instancetype)initIncludingAncestors:(BOOL)includeAncestors
{
	self = [super init];
	if (self) {
		_includesAncestors = includeAncestors;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initIncludingAncestors:NO];
}

#pragma mark - Getters and setters

- (BOOL)includesAncestors
{
	return _includesAncestors;
}

- (AKBehaviorToken *)behaviorToken
{
	DIGSLogError_MissingOverride();
	return nil;
}

- (NSArray *)memberTokensForBehavior:(AKBehaviorToken *)behaviorToken
{
	DIGSLogError_MissingOverride();
	return nil;
}

#pragma mark - AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
	NSDictionary *methodTokensByName = [self _subtopicMethodsByName];
	NSArray *sortedMethodNames = [methodTokensByName.allKeys
								  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	for (NSString *methodName in sortedMethodNames) {
		[docList addObject:methodTokensByName[methodName]];
	}
}

#pragma mark - Private methods

// Get a list of all behaviors that declare methods we want to
// include in our doc list.
- (NSArray *)_ancestorItemsWeCareAbout
{
	if (self.behaviorToken == nil) {
		return @[];
	}

	// Get a list of all behaviors that declare methods we want to list.
	NSMutableArray *ancestorItems = [NSMutableArray arrayWithObject:self.behaviorToken];

	if (_includesAncestors) {
		// Add superclasses to the list.  We will check nearest
		// superclasses first.
		if (self.behaviorToken.isClassToken) {
			AKClassToken *classToken = (AKClassToken *)self.behaviorToken;
			while ((classToken = classToken.parentClass)) {
				[ancestorItems addObject:classToken];
			}
		}

		// Add protocols we conform to to the list.  They will
		// be the last behaviors we check.
		[ancestorItems addObjectsFromArray:[self.behaviorToken implementedProtocols]];
	}

	return ancestorItems;
}

- (NSDictionary *)_subtopicMethodsByName
{
	// Match each inherited method name to the ancestor we get it from.
	// Because of the order in which we traverse ancestors, the
	// the *earliest* ancestor that implements each method is what will
	// remain in the dictionary.
	NSMutableDictionary *methodsByName = [NSMutableDictionary dictionary];

	for (AKBehaviorToken *ancestorItem in [self _ancestorItemsWeCareAbout]) {
		for (AKMethodToken *methodToken in [self memberTokensForBehavior:ancestorItem]) {
			methodsByName[methodToken.tokenName] = methodToken;
		}
	}
	
	return methodsByName;
}

@end
