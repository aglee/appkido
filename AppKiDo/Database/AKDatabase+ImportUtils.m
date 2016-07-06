//
//  AKDatabase+ImportUtils.m
//  AppKiDo
//
//  Created by Andy Lee on 5/28/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKManagedObjectQuery.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "DocSetIndex.h"

@implementation AKDatabase (ImportUtils)

- (AKManagedObjectQuery *)_queryWithEntityName:(NSString *)entityName
{
	return [[AKManagedObjectQuery alloc] initWithMOC:self.docSetIndex.managedObjectContext entityName:entityName];
}

- (NSArray *)_fetchTokenMOsWithLanguage:(NSString *)languageName tokenType:(NSString *)tokenType
{
	// Construct the predicate.
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"language.fullName = %@", languageName];
	if (tokenType.length) {
		NSPredicate *tokenTypePredicate = [NSPredicate predicateWithFormat:@"tokenType.typeName = %@", tokenType];
		predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate,
																		 tokenTypePredicate]];
	}

	// Perform the query.
	AKManagedObjectQuery *query = [self _queryWithEntityName:@"Token"];
	query.predicate = predicate;
	AKResult *result = [query fetchObjects];
	return result.object;  //TODO: Handle error.
}

- (NSDictionary *)_parsePossibleCategoryName:(NSString *)name
{
	// Workarounds for typos in the docsets.
	if ([name isEqualToString:@"NSObjectIOBluetoothHostControllerDelegate"]) {
		// In the macOS 10.11.4 docset index, the token named
		// "NSObjectIOBluetoothHostControllerDelegate" has token type "cl" but
		// is actually a category.  The name should have had parens like this:
		// "NSObject(IOBluetoothHostControllerDelegate)".  TODO: File a Radar.
		return @{ @1: @"NSObject",
				  @2: @"IOBluetoothHostControllerDelegate" };
	} else if ([name isEqualToString:@"AVAudioPCMBufer"]) {
		// In the macOS 10.11.4 docset index, the class name "AVAudioPCMBuffer"
		// is misspelled as "AVAudioPCMBufer".  TODO: File a Radar.
		return @{ @1: @"AVAudioPCMBuffer" };
	} else if ([name isEqualToString:@"MPSimageThresholdToZeroInverse"]) {
		// In the iOS 9.3 docset index, "MPSImageThresholdToZeroInverse" is
		// misspelled as "MPSimageThresholdToZeroInverse" (lower case "i").
		return @{ @1: @"MPSImageThresholdToZeroInverse" };
	}

	// Use a regex to parse the class name and category name.
	static NSRegularExpression *s_regexForCategoryNames;
	static dispatch_once_t once;
	dispatch_once(&once,^{
		s_regexForCategoryNames = [AKRegexUtils constructRegexWithPattern:@"(%ident%)(?:\\((%ident%)\\))?"].object;
		NSAssert(s_regexForCategoryNames != nil, @"%s Failed to construct regex.", __PRETTY_FUNCTION__);
	});
	AKResult *result = [AKRegexUtils matchRegex:s_regexForCategoryNames toEntireString:name];
	NSDictionary *captureGroups = result.object;
	return captureGroups;
}

@end
