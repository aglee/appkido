//
//  AKDatabase+ImportUtils.m
//  AppKiDo
//
//  Created by Andy Lee on 5/28/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKManagedObjectQuery.h"
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

@end
