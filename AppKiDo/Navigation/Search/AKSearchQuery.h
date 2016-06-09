/*
 * AKSearchQuery.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, AKSearchComparison) {
	AKSearchForSubstring = 0,
	AKSearchForExactMatch = 1,
	AKSearchForPrefix = 2,
};

@class AKDatabase;
@class AKToken;

/*!
 * Searches the tokens in an AKDatabase, subject to a set of search parameters.
 * Caches search results. Clears the cache whenever a search parameter changes.
 *
 * Does not detect changes to the database, which means the cached search
 * results could be incorrect if the database contents have changed since the
 * last time a search was performed.
 */
@interface AKSearchQuery : NSObject

@property (nonatomic, assign) BOOL includesClassesAndProtocols;
/*!
 * If true, searches properties, methods (including delegate methods), and
 * notifications. If the search string has the form "setXYZ", searches for a
 * property whose name begins with "XYZ".
 */
@property (nonatomic, assign) BOOL includesMembers;
@property (nonatomic, assign) BOOL includesFunctionsAndGlobals;
@property (nonatomic, assign) BOOL ignoresCase;
@property (nonatomic, assign) AKSearchComparison searchComparison;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)db NS_DESIGNATED_INITIALIZER;

#pragma mark - Searching

/*! Returns a sorted array of AKDocLocators. */
- (NSArray *)doSearchForString:(NSString *)searchString;

/*! Sets all the includesXXX properties to YES. */
- (void)includeEverythingInSearch;

@end
