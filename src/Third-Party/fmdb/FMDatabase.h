#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMResultSet.h"
#import "FMDatabasePool.h"


#if ! __has_feature(objc_arc)
    #define FMDBAutorelease(__v) ([__v autorelease]);
    #define FMDBReturnAutoreleased FMDBAutorelease

    #define FMDBRetain(__v) ([__v retain]);
    #define FMDBReturnRetained FMDBRetain

    #define FMDBRelease(__v) ([__v release]);
#else
    // -fobjc-arc
    #define FMDBAutorelease(__v)
    #define FMDBReturnAutoreleased(__v) (__v)

    #define FMDBRetain(__v)
    #define FMDBReturnRetained(__v) (__v)

    #define FMDBRelease(__v)
#endif


@interface FMDatabase : NSObject  {
    
    sqlite3*            _db;
    NSString*           _databasePath;
    BOOL                _logsErrors;
    BOOL                _crashOnErrors;
    BOOL                _traceExecution;
    BOOL                _checkedOut;
    BOOL                _shouldCacheStatements;
    BOOL                _isExecutingStatement;
    BOOL                _inTransaction;
    int                 _busyRetryTimeout;
    
    NSMutableDictionary *_cachedStatements;
    NSMutableSet        *_openResultSets;
    NSMutableSet        *_openFunctions;

}


@property (atomic, assign) BOOL traceExecution;
@property (atomic, assign) BOOL checkedOut;
@property (atomic, assign) int busyRetryTimeout;
@property (atomic, assign) BOOL crashOnErrors;
@property (atomic, assign) BOOL logsErrors;
@property (atomic, strong) NSMutableDictionary *cachedStatements;


+ (instancetype)databaseWithPath:(NSString*)inPath;
- (instancetype)initWithPath:(NSString*)inPath NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL open;
#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags;
#endif
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL close;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL goodConnection;
- (void)clearCachedStatements;
- (void)closeOpenResultSets;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasOpenResultSets;

// encryption methods.  You need to have purchased the sqlite encryption extensions for these to work.
- (BOOL)setKey:(NSString*)key;
- (BOOL)rekey:(NSString*)key;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *databasePath;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *lastErrorMessage;

@property (NS_NONATOMIC_IOSONLY, readonly) int lastErrorCode;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hadError;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSError *lastError;

@property (NS_NONATOMIC_IOSONLY, readonly) sqlite_int64 lastInsertRowId;

@property (NS_NONATOMIC_IOSONLY, readonly) sqlite3 *sqliteHandle;

- (BOOL)update:(NSString*)sql withErrorAndBindings:(NSError**)outErr, ...;
- (BOOL)executeUpdate:(NSString*)sql, ...;
- (BOOL)executeUpdateWithFormat:(NSString *)format, ...;
- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;

- (FMResultSet *)executeQuery:(NSString*)sql, ...;
- (FMResultSet *)executeQueryWithFormat:(NSString*)format, ...;
- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (FMResultSet *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL rollback;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL commit;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL beginTransaction;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL beginDeferredTransaction;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL inTransaction;
@property (NS_NONATOMIC_IOSONLY) BOOL shouldCacheStatements;

#if SQLITE_VERSION_NUMBER >= 3007000
- (BOOL)startSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (BOOL)releaseSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (BOOL)rollbackToSavePointWithName:(NSString*)name error:(NSError**)outErr;
- (NSError*)inSavePoint:(void (^)(BOOL *rollback))block;
#endif

+ (BOOL)isSQLiteThreadSafe;
+ (NSString*)sqliteLibVersion;

@property (NS_NONATOMIC_IOSONLY, readonly) int changes;

- (void)makeFunctionNamed:(NSString*)name maximumArguments:(int)count withBlock:(void (^)(sqlite3_context *context, int argc, sqlite3_value **argv))block;

@end

@interface FMStatement : NSObject {
    sqlite3_stmt *_statement;
    NSString *_query;
    long _useCount;
}

@property (atomic, assign) long useCount;
@property (atomic, strong) NSString *query;
@property (atomic, assign) sqlite3_stmt *statement;

- (void)close;
- (void)reset;

@end

