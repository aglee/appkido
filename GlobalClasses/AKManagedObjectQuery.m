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
#import "QuietLog.h"

#define MyErrorDomain @"com.appkido.AppKiDo"

@interface AKManagedObjectQuery ()
@property (strong) NSManagedObjectContext *moc;
@property (copy) NSString *entityName;
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
    return [self _fetchObjectsDistinct:NO];
}

- (AKResult *)fetchDistinctObjects
{
    return [self _fetchObjectsDistinct:YES];
}

#pragma mark - Private methods - handling fetch requests

- (AKResult *)_fetchObjectsDistinct:(BOOL)distinct
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

    // Try to execute the fetch request.
    return [self _executeFetchRequest:fetchRequest];
}

- (AKResult *)_createFetchRequest
{
	// Require the entity name to be a non-empty identifier.
	NSDictionary *captureGroups = [AKRegexUtils matchPattern:@"%ident%" toEntireString:self.entityName];
	if (captureGroups == nil) {
        return [AKResult failureResultWithErrorDomain:MyErrorDomain
                                                 code:9999
                                          description:@"Entity name is not a valid identifier."];
	}

	// Try to make an NSPredicate, if one was specified.
	NSPredicate *predicate = nil;
	if (self.predicateString.length) {
        AKResult *result = [self _createPredicate];
        if (result.error) {
            return result;
        }
		predicate = result.object;
	}

	// If we got this far, we can construct the fetch request.
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	fetchRequest.predicate = predicate;
	return [AKResult successResultWithObject:fetchRequest];
}

- (AKResult *)_createPredicate
{
	@try {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:self.predicateString];
		return [AKResult successResultWithObject:predicate];
	}
	@catch (NSException *ex) {
		if ([ex.name isEqualToString:NSInvalidArgumentException]) {
			return [AKResult failureResultWithErrorDomain:MyErrorDomain
                                                     code:9999
                                              description:@"Invalid predicate string."];
		} else {
			@throw ex;
		}
	}
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
