//
//  DocSetQuery.m
//  AppKiDo
//
//  Created by Andy Lee on 4/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "DocSetQuery.h"
#import "DocSetIndex.h"
#import "QuietLog.h"
#import <WebKit/WebKit.h>

#define MyErrorDomain @"com.appkido.AppKiDo"

@interface DocSetQuery ()

@property (strong) DocSetIndex *docSetIndex;
@property (copy) NSString *entityName;

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex entity:(NSString *)entityName NS_DESIGNATED_INITIALIZER;

@end

#pragma mark -

@implementation DocSetQuery

#pragma mark - Factory methods

+ (instancetype)queryWithDocSetIndex:(DocSetIndex *)docSetIndex entityName:(NSString *)entityName
{
    return [[self alloc] initWithDocSetIndex:docSetIndex entity:entityName];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex entity:(NSString *)entityName
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
    return [self initWithDocSetIndex:nil entity:nil];
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

#pragma mark - Private methods - regexes

- (NSString *)_makeAllWhitespaceStretchyInPattern:(NSString *)pattern
{
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:NULL];

	pattern = [regex stringByReplacingMatchesInString:pattern options:0 range:NSMakeRange(0, pattern.length) withTemplate:@"(?:\\\\s+)"];

	return pattern;
}

// Replaces %ident%, %lit%, %keypath% with canned sub-patterns.
// Ignores leading and trailing whitespace with \\s*.
// Allows internal whitespace to be any length of any whitespace.
// Returns dictionary with NSNumber keys indication position of capture group (1-based).
// Returns nil if invalid pattern.
- (NSDictionary *)_matchPattern:(NSString *)pattern toEntireString:(NSString *)inputString
{
	// Assume leading and trailing whitespace can be ignored, and remove it from both the input string and the pattern.
	inputString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (inputString.length == 0) {
		QLog(@"%@", @"Can't handle empty string");
		return nil;  //TODO: Revisit how to handle nil.
	}
	pattern = [pattern stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	// Interpret any internal whitespace in the pattern as meaning "non-empty whitespace of any length".
	pattern = [self _makeAllWhitespaceStretchyInPattern:pattern];

	// Expand %...% placeholders.  Replace %keypath% before replacing %ident%, because the expansion of %keypath% contains "%ident%".
	pattern = [pattern stringByReplacingOccurrencesOfString:@"%keypath%" withString:@"(?:(?:%ident%(?:\\.%ident%)*)(?:\\.@count)?)"];
	pattern = [pattern stringByReplacingOccurrencesOfString:@"%ident%" withString:@"(?:[A-Za-z][0-9A-Za-z]*)"];
	pattern = [pattern stringByReplacingOccurrencesOfString:@"%lit%" withString:@"(?:(?:[^\"]|(?:\\\"))*)"];

	// Apply the regex to the input string.
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];

	if (regex == nil) {
		QLog(@"regex construction error: %@", error);
		return nil;
	}

	NSRange rangeOfEntireString = NSMakeRange(0, inputString.length);
	NSTextCheckingResult *matchResult = [regex firstMatchInString:inputString options:0 range:rangeOfEntireString];
	if (matchResult == nil) {
		QLog(@"%@", @"failed to match regex");
		return nil;
	} else if (!NSEqualRanges(matchResult.range, rangeOfEntireString)) {
		QLog(@"%@", @"regex did not match entire string");
		return nil;
	}

	// Collect all the capture groups that were matched.  We start iterating at 1 because the zeroeth capture group is the entire matching string.
	NSMutableDictionary *captureGroupsByIndex = [NSMutableDictionary dictionary];
	for (NSUInteger rangeIndex = 1; rangeIndex < matchResult.numberOfRanges; rangeIndex++) {
		NSRange captureGroupRange = [matchResult rangeAtIndex:rangeIndex];
		if (captureGroupRange.location != NSNotFound) {
			captureGroupsByIndex[@(rangeIndex)] = [inputString substringWithRange:captureGroupRange];
		}
	}
	//	QLog(@"parse result: %@", captureGroupsByIndex);
	[[captureGroupsByIndex.allKeys sortedArrayUsingSelector:@selector(compare:)] enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		QLog(@"    @%@: [%@]", obj, captureGroupsByIndex[obj]);
	}];

	return captureGroupsByIndex;
}

#pragma mark - Private methods - handling fetch commands

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
	NSDictionary *captureGroups = [self _matchPattern:@"%ident%" toEntireString:self.entityName];
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
		if (![self _matchPattern:@"%keypath%" toEntireString:expectedKeyPath]) {
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
