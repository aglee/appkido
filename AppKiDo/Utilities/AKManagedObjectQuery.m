//
//  AKManagedObjectQuery.m
//  AppKiDo
//
//  Created by Andy Lee on 4/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKManagedObjectQuery.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "DIGSLog.h"

#define MyErrorDomain @"com.appkido.AppKiDo"

@interface AKManagedObjectQuery ()
@property (readonly) NSManagedObjectContext *moc;
@property (readonly) NSString *entityName;
@end

@implementation AKManagedObjectQuery

#pragma mark - Init/awake/dealloc

- (instancetype)initWithMOC:(NSManagedObjectContext *)moc entityName:(NSString *)entityName
{
	NSParameterAssert(moc != nil);
	NSParameterAssert(entityName != nil);
	self = [super init];
	if (self) {
		_moc = moc;
		_entityName = entityName;
		_returnsObjectsAsFaults = YES;
	}
	return self;
}

- (instancetype)init
{
	return [self initWithMOC:nil entityName:nil];
}

#pragma mark - Executing fetch requests

- (AKResult *)fetchObjects
{
	return [self _fetchDistinctObjects:NO];
}

- (AKResult *)fetchDistinctObjects
{
	return [self _fetchDistinctObjects:YES];
}

#pragma mark - Private methods - handling fetch requests

- (AKResult *)_fetchDistinctObjects:(BOOL)distinct
{
	AKResult *result;

	// Try to construct the fetch request.
	result = [self _createFetchRequest];
	if (result.error) {
		return result;
	}

	NSFetchRequest *fetchRequest = result.object;
	if (distinct) {
		fetchRequest.returnsDistinctResults = YES;
		fetchRequest.resultType = NSDictionaryResultType;
		fetchRequest.propertiesToFetch = self.keyPaths;
	}
	fetchRequest.returnsObjectsAsFaults = self.returnsObjectsAsFaults;

	// Try to execute the fetch request.
	return [self _executeFetchRequest:fetchRequest];
}

- (AKResult *)_createFetchRequest
{
	// Require the entity name to be a non-empty identifier.
	NSDictionary *captureGroups = [AKRegexUtils matchPattern:@"%ident%" toEntireString:self.entityName].object;
	if (captureGroups == nil) {
		return [AKResult failureResultWithErrorDomain:MyErrorDomain
												 code:9999
										  description:@"Entity name is not a valid identifier."];
	}

	// If we got this far, we can construct the fetch request.
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	fetchRequest.predicate = self.predicate;
	return [AKResult successResultWithObject:fetchRequest];
}

- (AKResult *)_executeFetchRequest:(NSFetchRequest *)fetchRequest
{
	@try {
		NSError *error;
		NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
		return (fetchedObjects
				? [AKResult successResultWithObject:fetchedObjects]
				: [AKResult failureResultWithError:error]);
	}
	@catch (NSException *ex) {
		NSString *errorMessage = [NSString stringWithFormat:@"Failed to fetch data: %@.", ex];
		return [AKResult failureResultWithErrorDomain:MyErrorDomain
												 code:9999
										  description:errorMessage];
	}
}

@end
