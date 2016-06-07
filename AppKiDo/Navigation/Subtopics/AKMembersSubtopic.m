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
#import "AKMemberToken.h"
#import "NSArray+AppKiDo.h"

@interface AKMembersSubtopic ()
@property (strong) AKBehaviorToken *behaviorToken;
@property (assign) BOOL includesAncestors;
@end

@implementation AKMembersSubtopic

// What kind of members do we want -- class methods, instance methods, etc.?
- (NSArray *)memberTokensForBehavior:(AKBehaviorToken *)behaviorToken
{
	DIGSLogError_MissingOverride();
	return nil;
}

- (NSArray *)arrayWithDocListItems
{
	NSMutableArray *docList = [NSMutableArray array];
	NSDictionary *memberTokensByName = [self _subtopicMembersByName];
	for (NSString *memberName in [memberTokensByName.allKeys ak_sortedStrings]) {
		[docList addObject:memberTokensByName[memberName]];
	}
	return docList;
}

#pragma mark - Private methods

// Get a list of all behaviors, including self.behaviorToken, that have members
// we want to include.
- (NSArray *)_ancestorBehaviorsWeCareAbout
{
	if (self.behaviorToken == nil) {
		return @[];
	}

	// Get a list of all behaviors that declare members we want to list.
	NSMutableArray *ancestorItems = [NSMutableArray arrayWithObject:self.behaviorToken];

	if (self.includesAncestors) {
		// Add superclasses to the list.  We will check nearest
		// superclasses first.
		if (self.behaviorToken.isClassToken) {
			AKClassToken *classToken = (AKClassToken *)self.behaviorToken;
			while ((classToken = classToken.superclassToken)) {
				[ancestorItems addObject:classToken];
			}
		}

		// Add protocols we conform to to the list.  They will
		// be the last behaviors we check.
		[ancestorItems addObjectsFromArray:[self.behaviorToken adoptedProtocols]];
	}

	return ancestorItems;
}

- (NSDictionary *)_subtopicMembersByName
{
	// Match each inherited member name to the ancestor we get it from.
	// Because of the order in which we traverse ancestors, the
	// the *earliest* ancestor that has each member is what will
	// remain in the dictionary.
	NSMutableDictionary *membersByName = [NSMutableDictionary dictionary];

	for (AKBehaviorToken *ancestorItem in [self _ancestorBehaviorsWeCareAbout]) {
		for (AKMemberToken *memberToken in [self memberTokensForBehavior:ancestorItem]) {
			membersByName[memberToken.name] = memberToken;
		}
	}
	
	return membersByName;
}

@end
