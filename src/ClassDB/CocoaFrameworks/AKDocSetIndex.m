/*
 *  AKDocSetIndex.m
 *
 *  Created by Andy Lee on 1/6/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import "AKDocSetIndex.h"

#import "AKFileUtils.h"
#import "AKSQLTemplate.h"

#import "FMDatabase.h"

@implementation AKDocSetIndex

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithDocSetPath:(NSString *)docSetPath basePathForHeaders:(NSString *)basePathForHeaders
{
    DIGSLogDebug(@"initWithDocSetPath:basePathForHeaders: -- [%@], [%@]", docSetPath, basePathForHeaders);

    if ((self = [super init]))
    {
        _docSetPath = [docSetPath copy];
        _basePathForHeaders = [basePathForHeaders copy];

        DIGSLogInfo(@"docset index -- [%@]", [self _pathToSqliteFile]);
        
        BOOL isDir;
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self _pathToSqliteFile] isDirectory:&isDir])
        {
            DIGSLogDebug(@"AKDocSetIndex -- There is no docset at [%@]", _docSetPath);
            return nil;
        }
        else if (isDir)
        {
            DIGSLogDebug(@"AKDocSetIndex -- Dsidx path [%@] is a directory, not a file", [self _pathToSqliteFile]);
            return nil;
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:_basePathForHeaders isDirectory:&isDir])
        {
            DIGSLogWarning(@"AKDocSetIndex -- There is no directory [%@]", _basePathForHeaders);
            return nil;
        }
        else if (!isDir)
        {
            DIGSLogDebug(@"AKDocSetIndex -- Header path [%@] is a file, not a directory", _basePathForHeaders);
            return nil;
        }
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark Getters and setters

- (NSString *)docSetPath
{
    return _docSetPath;
}

- (NSArray *)selectableFrameworkNames
{
    static NSMutableArray *s_selectableFrameworkNames = nil;

    if (s_selectableFrameworkNames == nil)
    {
#if APPKIDO_FOR_IPHONE
        s_selectableFrameworkNames = [[self _allFrameworkNames] retain];
#else
        s_selectableFrameworkNames = [self _objectiveCFrameworkNames];

        [s_selectableFrameworkNames removeObject:@"Carbon"];  // [agl] KLUDGE -- why is carbon returned by the query??
        [s_selectableFrameworkNames addObject:@"ApplicationServices"];  // [agl] KLUDGE -- to get CGPoint etc.
#endif

        // Force essential framework names to the top of the list.
        [self _forceEssentialFrameworkNamesToTopOfList:s_selectableFrameworkNames];
    }

    return s_selectableFrameworkNames;
}

- (NSString *)basePathForHeaders
{
    return _basePathForHeaders;
}

- (NSArray *)headerPathsForFramework:(NSString *)frameworkName
{
    // Open the database.
    FMDatabase* sqliteDB = [self _openSQLiteDB];
    if (sqliteDB == nil)
    {
        return nil;
    }

    // Do the query and process the results.
    NSMutableArray *headerFiles = [NSMutableArray array];
    NSString *sql = [AKSQLTemplate templateNamed:@"HeaderPaths"];
    FMResultSet *rs = [sqliteDB executeQuery:sql, frameworkName];

    while ([rs next])
    {
        [headerFiles addObject:[rs stringForColumnIndex:0]];
    }
    [rs close];  

    // Close the database.
    [sqliteDB close];

    return headerFiles;
}

- (NSSet *)headerDirsForFramework:(NSString *)frameworkName
{
    // Open the database.
    FMDatabase* sqliteDB = [self _openSQLiteDB];
    if (sqliteDB == nil)
    {
        return nil;
    }

    // Do the query and process the results.
    NSMutableSet *headerDirs = [NSMutableSet set];
    NSString *sql = [AKSQLTemplate templateNamed:@"HeaderPaths"];
    FMResultSet *rs = [sqliteDB executeQuery:sql, frameworkName];

    while ([rs next])
    {
        NSString *headerFilePath = [rs stringForColumnIndex:0];
        NSString *headerDirPath = headerFilePath.stringByDeletingLastPathComponent;

        if (_basePathForHeaders)
        {
            headerDirPath = [_basePathForHeaders stringByAppendingPathComponent:headerDirPath];
        }
        
        [headerDirs addObject:headerDirPath];
    }
    [rs close];  

    // Close the database.
    [sqliteDB close];

    return headerDirs;
}

- (NSString *)baseDirForDocs
{
    return [[self _resourcesPath] stringByAppendingPathComponent: @"Documents"];
}

- (NSArray *)behaviorDocPathsForFramework:(NSString *)frameworkName
{
    return [self _docPathsForTokensOfType:@"cl"
                                   orType:@"intf"
                                   orType:@"clm"
                                   orType:@"instm"  // to pick up "XXX Additions Reference"
                             forFramework:frameworkName];
}

- (NSArray *)functionsDocPathsForFramework:(NSString *)frameworkName
{
    return [self _docPathsForTokensOfType:@"func"
                                   orType:@"macro"
                             forFramework:frameworkName];
}

- (NSArray *)globalsDocPathsForFramework:(NSString *)frameworkName
{
    return [self _docPathsForTokensOfType:@"econst"
                                   orType:@"data"
                                   orType:@"tdef"
                             forFramework:frameworkName];

/* [agl] I don't think we need to filter globals file names when we have a docset.
    // KLUDGE -- Globals are declared in many files, but currently we only
    // know how to parse the kind that have "Constants" or "DataTypes" in
    // their path, e.g.,
    // ApplicationKit/Miscellaneous/AppKit_DataTypes/Reference/reference.html.
    NSMutableArray * result = [NSMutableArray array];
    NSEnumerator *en =
        [[self
            _docPathsForTokensOfType:@"econst"
            orType:@"data"
            orType:@"tdef"
            forFramework:frameworkName] objectEnumerator];
    NSString *path;

    while ((path = [en nextObject]))
    {
        if ([path ak_contains:@"Constants"] || [path ak_contains:@"DataTypes"])
        {
            [result addObject:path];
        }
    }

    return result;
*/
}

- (NSString *)relativePathToDocsForClassNamed:(NSString *)nameOfClass
{
    // Open the database.
    FMDatabase* sqliteDB = [self _openSQLiteDB];
    if (sqliteDB == nil)
    {
        return nil;
    }

    // Do the query and process the results.
    NSString *docPath = nil;
    NSString *sql = [AKSQLTemplate templateNamed:@"DocPathForClass"];
    FMResultSet *rs = [sqliteDB executeQuery:sql, nameOfClass];

    while ([rs next])
    {
        if (docPath)
        {
            DIGSLogWarning(@"Found more than one doc file for class '%@'.  In addition to '%@', found '%@'.  Will return the last one found.",
                           nameOfClass, docPath, [rs stringForColumnIndex:0]);
        }

        docPath = [rs stringForColumnIndex:0];
    }
    [rs close];

    // Close the database.
    [sqliteDB close];

    return docPath;
}

#pragma mark -
#pragma mark Private methods

- (NSMutableArray *)_allFrameworkNames
{
    NSString *sql = [AKSQLTemplate templateNamed:@"AllFrameworkNames"];
    return [self _stringArrayFromQuery:sql];
}

- (NSMutableArray *)_objectiveCFrameworkNames
{
    NSString *sql = [AKSQLTemplate templateNamed:@"ObjCFrameworkNames"];
    return [self _stringArrayFromQuery:sql];
}

- (NSMutableArray *)_stringArrayFromQuery:(NSString *)queryString
{
    NSMutableArray *stringArray = [NSMutableArray array];

    // Open the database.
    FMDatabase *sqliteDB = [self _openSQLiteDB];
    if (sqliteDB == nil)
    {
        return nil;
    }

    // Query the database and process the results.
    FMResultSet *rs = [sqliteDB executeQuery:queryString];
    while ([rs next])
    {
        NSString *fwName = [rs stringForColumnIndex:0];
        
        if (fwName)
        {
            [stringArray addObject:fwName];
        }
    }
    [rs close];

    // Close the database.
    [sqliteDB close];

    return stringArray;
}

- (NSMutableSet *)_docPathsFromQuery:(NSString *)queryString
                       withTokenType:(NSString *)tokenType1
                              orType:(NSString *)tokenType2
                              orType:(NSString *)tokenType3
                              orType:(NSString *)tokenType4
                        forFramework:(NSString *)frameworkName
{
    NSMutableSet *setOfStrings = [NSMutableSet set];
    
    // Open the database.
    FMDatabase* sqliteDB = [self _openSQLiteDB];
    if (sqliteDB == nil)
    {
        return nil;
    }
    
    // Query the database and process the results.
    FMResultSet *rs = [sqliteDB executeQuery:queryString,
                       frameworkName,
                       tokenType1,
                       tokenType2,
                       tokenType3,
                       tokenType4];
    while ([rs next])
    {
        NSString *fwName = [rs stringForColumnIndex:0];
        [setOfStrings addObject:fwName];
    }
    [rs close];
    
    // Close the database.
    [sqliteDB close];
    
    return setOfStrings;
}

- (NSString *)_resourcesPath
{
    return [_docSetPath stringByAppendingPathComponent:@"Contents/Resources"];
}

- (NSString *)_pathToSqliteFile
{
    return [[self _resourcesPath] stringByAppendingPathComponent:@"docSet.dsidx"];
}

- (FMDatabase *)_openSQLiteDB
{
    FMDatabase* sqliteDB = [FMDatabase databaseWithPath:[self _pathToSqliteFile]];

    if (![sqliteDB open])
    {
        DIGSLogError(@"%@", @"Could not open db.");
        return nil;
    }

    return sqliteDB;
}

- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType
    forFramework:(NSString *)frameworkName
{
    return [self _docPathsForTokensOfType:tokenType
                                   orType:nil
                                   orType:nil
                                   orType:nil
                             forFramework:frameworkName];
}

- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType1
                               orType:(NSString *)tokenType2
                         forFramework:(NSString *)frameworkName
{
    return [self _docPathsForTokensOfType:tokenType1
                                   orType:tokenType2
                                   orType:nil
                                   orType:nil
                             forFramework:frameworkName];
}

- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType1
                               orType:(NSString *)tokenType2
                               orType:(NSString *)tokenType3
                         forFramework:(NSString *)frameworkName
{
    return [self _docPathsForTokensOfType:tokenType1
                                   orType:tokenType2
                                   orType:tokenType3
                                   orType:nil
                             forFramework:frameworkName];
}

- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType1
                               orType:(NSString *)tokenType2
                               orType:(NSString *)tokenType3
                               orType:(NSString *)tokenType4
                         forFramework:(NSString *)frameworkName
{
    // Make sure we pass non-nil for all four tokenType arguments.
    if (tokenType2 == nil)
    {
        tokenType2 = tokenType1;
    }

    if (tokenType3 == nil)
    {
        tokenType3 = tokenType1;
    }

    if (tokenType4 == nil)
    {
        tokenType4 = tokenType1;
    }

    // Query the database. See the comment for s_docPathsSecondQueryTemplate
    // to see why we do two queries.
    NSString *docPathsQueryTemplate = [AKSQLTemplate templateNamed:@"DocPaths"];
    NSString *docPathsSecondQueryTemplate = [AKSQLTemplate templateNamed:@"DocPaths2"];
    
    NSMutableSet *docPaths = [self _docPathsFromQuery:docPathsQueryTemplate
                                        withTokenType:tokenType1
                                               orType:tokenType2
                                               orType:tokenType3
                                               orType:tokenType4
                                         forFramework:frameworkName];
    
    [docPaths unionSet:[self _docPathsFromQuery:docPathsSecondQueryTemplate
                                  withTokenType:tokenType1
                                         orType:tokenType2
                                         orType:tokenType3
                                         orType:tokenType4
                                   forFramework:frameworkName]];

    return docPaths.allObjects;
}

- (void)_forceEssentialFrameworkNamesToTopOfList:(NSMutableArray *)fwNames
{
    for (NSString *essentialFrameworkName in [AKNamesOfEssentialFrameworks reverseObjectEnumerator])
    {
        if ([fwNames containsObject:essentialFrameworkName])
        {
            [fwNames removeObject:essentialFrameworkName];
            [fwNames insertObject:essentialFrameworkName atIndex:0];
        }
    }
}

@end
