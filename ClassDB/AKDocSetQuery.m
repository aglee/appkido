//
//  AKDocSetQuery.m
//  AppKiDo
//
//  Created by Andy Lee on 4/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDocSetQuery.h"
#import "AKRegexUtils.h"
#import "DocSetIndex.h"
#import "QuietLog.h"
#import <WebKit/WebKit.h>

#define MyErrorDomain @"com.appkido.AppKiDo"

@interface AKDocSetQuery ()
@property (strong) DocSetIndex *docSetIndex;
@property (copy) NSString *entityName;
@end

#pragma mark -

@implementation AKDocSetQuery

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex entityName:(NSString *)entityName
{
    NSParameterAssert(docSetIndex != nil);
    NSParameterAssert(entityName != nil);
    self = [super init];
    if (self) {
        _docSetIndex = docSetIndex;
        _entityName = entityName;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithDocSetIndex:nil entityName:nil];
}

#pragma mark - Querying the DocSetIndex

- (NSArray *)fetchObjectsWithError:(NSError **)errorPtr
{
    NSError *error;
    NSArray *fetchedObjects = [self _fetchObjectsWithError:errorPtr];
    if (fetchedObjects == nil) {
        QLog(@"+++ %s [ERROR] %@", error);
    }
    return fetchedObjects;
}

#pragma mark - Private methods - handling fetch commands

- (NSArray *)_fetchObjectsWithError:(NSError **)errorPtr
{
    // Try to construct the fetch request.
    NSFetchRequest *fetchRequest = [self _createFetchRequestWithError:errorPtr];
    if (fetchRequest == nil) {
        return nil;
    }

    // If distinct key paths were specified, modify the fetch request accordingly.
    if (self.distinctKeyPathsString.length) {
        NSArray *keyPaths = [self _parseKeyPathsStringWithError:errorPtr];

        if (keyPaths == nil) {
            return nil;
        }

        fetchRequest.returnsDistinctResults = YES;
        fetchRequest.resultType = NSDictionaryResultType;
        fetchRequest.propertiesToFetch = keyPaths;
    }

    // Try to execute the fetch request.
    return [self _executeFetchRequest:fetchRequest error:errorPtr];
}

- (NSArray *)_executeFetchRequest:(NSFetchRequest *)fetchRequest error:(NSError **)errorPtr
{
	@try {
		NSArray *fetchedObjects = [self.docSetIndex.managedObjectContext executeFetchRequest:fetchRequest error:errorPtr];
        return fetchedObjects;
	}
	@catch (NSException *ex) {
        if (errorPtr) {
            NSString *errorMessage = [NSString stringWithFormat:@"Exception during attempt to fetch data: %@. Error: %@.", ex, (errorPtr ? *errorPtr : @"unknown")];
            *errorPtr = [NSError errorWithDomain:MyErrorDomain code:9999 userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
        }
		return nil;
	}
}

- (NSFetchRequest *)_createFetchRequestWithError:(NSError **)errorPtr
{
	// Require the entity name to be a non-empty identifier.
	NSDictionary *captureGroups = [AKRegexUtils matchPattern:@"%ident%" toEntireString:self.entityName];
	if (captureGroups == nil) {
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:MyErrorDomain code:9999 userInfo:@{ NSLocalizedDescriptionKey : @"Entity name is not a valid identifier." }];
        }
		return nil;
	}

	// Try to make an NSPredicate, if one was specified.
	NSPredicate *predicate = nil;
	if (self.predicateString.length) {
		predicate = [self _createPredicateWithError:errorPtr];
		if (predicate == nil) {
			return nil;
		}
	}

	// If we got this far, everything is okay.
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	fetchRequest.predicate = predicate;
	return fetchRequest;
}

- (NSPredicate *)_createPredicateWithError:(NSError **)errorPtr
{
	@try {
		return [NSPredicate predicateWithFormat:self.predicateString];
	}
	@catch (NSException *ex) {
		if ([ex.name isEqualToString:NSInvalidArgumentException]) {
            if (errorPtr) {
                *errorPtr = [NSError errorWithDomain:MyErrorDomain code:9999 userInfo:@{ NSLocalizedDescriptionKey : @"Invalid predicate string." }];
            }
			return nil;
		} else {
			@throw ex;
		}
		return nil;
	}
}

- (NSArray *)_parseKeyPathsStringWithError:(NSError **)errorPtr
{
	NSMutableArray *keyPaths = [NSMutableArray array];
	NSDictionary *errorInfo;
	NSArray *commaSeparatedComponents = [self.distinctKeyPathsString componentsSeparatedByString:@","];
	for (__strong NSString *expectedKeyPath in commaSeparatedComponents) {
		expectedKeyPath = [expectedKeyPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (![AKRegexUtils matchPattern:@"%keypath%" toEntireString:expectedKeyPath]) {
            if (errorPtr) {
                NSString *errorMessage = [NSString stringWithFormat:@"'%@' is not a key path.  Make sure to comma-separate key paths.", expectedKeyPath];
                errorInfo = @{ NSLocalizedDescriptionKey : errorMessage };
                *errorPtr = [NSError errorWithDomain:MyErrorDomain code:9999 userInfo:errorInfo];
            }
			return nil;
		} else {
			[keyPaths addObject:expectedKeyPath];
		}
	}
	if (keyPaths.count == 0) {
        if (errorPtr) {
            errorInfo = @{ NSLocalizedDescriptionKey : @"One or more comma-separated key paths must be specified." };
            *errorPtr = [NSError errorWithDomain:MyErrorDomain code:9999 userInfo:errorInfo];
        }
		return nil;
	}
	return keyPaths;
}

@end
