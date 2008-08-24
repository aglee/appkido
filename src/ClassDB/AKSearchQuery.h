/*
 * AKSearchQuery.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

typedef enum {
    AKSearchSubstring = 0,
    AKSearchExactMatch = 1,
    AKSearchPrefix = 2,
} AKSearchComparison;

@class AKDatabase;

/*!
 * @class       AKSearchQuery
 * @abstract    Performs searches on an AKDatabase.
 * @discussion  An AKSearchQuery searches the nodes in an AKDatabase,
 *              subject to a set of search parameters.  Search results are
 *              returned as a sorted array of AKDatabaseNodes.
 *
 *              An AKSearchQuery caches its search results.  All of the
 *              -setXXX: methods clear the cache if they change a search
 *              parameter.  If there is no change, the cache is left alone.
 *
 *              An AKSearchQuery does not detect changes to the database,
 *              so the cached search results could be incorrect if the
 *              database contents have changed since the last time the
 *              search was performed.
 */
@interface AKSearchQuery : NSObject
{
@private
    AKDatabase *_database;
    NSString *_searchString;

    // Search flags.
    BOOL _includesClassesAndProtocols;
    BOOL _includesMembers;
    BOOL _includesFunctions;
    BOOL _includesGlobals;
    BOOL _ignoresCase;
    AKSearchComparison _searchComparison;

    // Cached search results.  The cache is cleared whenever the search
    // string or a search flag changes.
    NSMutableArray *_searchResults;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*!
 * @method      initWithDatabase:
 * @discussion  Designated initializer.
 */
- (id)initWithDatabase:(AKDatabase *)db;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)searchString;
- (void)setSearchString:(NSString *)s;

- (BOOL)includesClassesAndProtocols;
- (void)setIncludesClassesAndProtocols:(BOOL)flag;

- (BOOL)includesMembers;
- (void)setIncludesMembers:(BOOL)flag;

- (BOOL)includesFunctions;
- (void)setIncludesFunctions:(BOOL)flag;

- (BOOL)includesGlobals;
- (void)setIncludesGlobals:(BOOL)flag;

/*! Sends all the -setIncludesXXX: messages with YES as the flag. */
- (void)setIncludesEverything;

- (BOOL)ignoresCase;
- (void)setIgnoresCase:(BOOL)flag;

- (AKSearchComparison)searchComparison;
- (void)setSearchComparison:(AKSearchComparison)searchComparison;

//-------------------------------------------------------------------------
// Searching
//-------------------------------------------------------------------------

/*!
 * @method      queryResults
 * @discussion  Returns a sorted array of AKDocLocators.
 */
- (NSArray *)queryResults;

@end
