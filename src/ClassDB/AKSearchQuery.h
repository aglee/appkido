/*
 * AKSearchQuery.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

typedef enum {
    AKSearchForSubstring = 0,
    AKSearchForExactMatch = 1,
    AKSearchForPrefix = 2,
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
    NSRange _rangeForEntireSearchString;  // used for prefix searches;
                                          //  saves calls to NSMakeRange()
    // Search flags.
    BOOL _includesClassesAndProtocols;
    BOOL _includesMembers;
    BOOL _includesFunctions;
    BOOL _includesGlobals;
    BOOL _ignoresCase;
    AKSearchComparison _searchComparison;

    // Cached search results. Is set to nil whenever the search string or a
    // search flag changes. nil means the search needs to be (re)performed.
    NSMutableArray *_searchResults;
}

@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, assign) NSRange rangeForEntireSearchString;
@property (nonatomic, assign) BOOL includesClassesAndProtocols;
@property (nonatomic, assign) BOOL includesMembers;
@property (nonatomic, assign) BOOL includesFunctions;
@property (nonatomic, assign) BOOL includesGlobals;
@property (nonatomic, assign) BOOL ignoresCase;
@property (nonatomic, assign) AKSearchComparison searchComparison;

#pragma mark -
#pragma mark Factory methods

+ (id)withDatabase:(AKDatabase *)db;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithDatabase:(AKDatabase *)db;

#pragma mark -
#pragma mark Searching

/*! Sends all the -setIncludesXXX: messages with YES as the flag. */
- (void)includeEverythingInSearch;

/*! Returns a sorted array of AKDocLocators. */
- (NSArray *)queryResults;

@end
