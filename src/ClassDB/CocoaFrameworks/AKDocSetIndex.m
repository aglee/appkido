/*
 *  AKDocSetIndex.m
 *
 *  Created by Andy Lee on 1/6/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import "AKDocSetIndex.h"

#import "DIGSLog.h"
#import "FMDatabase.h"
#import "AKFrameworkConstants.h"
#import "AKTextUtils.h"
#import "AKFileUtils.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"


@interface AKDocSetIndex ()

- (NSMutableArray *)_allFrameworkNames;
- (NSMutableArray *)_objectiveCFrameworkNames;
- (NSMutableArray *)_stringArrayFromQuery:(NSString *)queryString;

- (NSString *)_resourcesPath;
- (NSString *)_pathToSqliteFile;
- (FMDatabase *)_openSQLiteDB;
- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType
    forFramework:(NSString *)frameworkName;
- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType
    orType:(NSString *)tokenType2
    forFramework:(NSString *)frameworkName;
- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType
    orType:(NSString *)tokenType2
    orType:(NSString *)tokenType3
    forFramework:(NSString *)frameworkName;
- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType
    orType:(NSString *)tokenType2
    orType:(NSString *)tokenType3
    orType:(NSString *)tokenType4
    forFramework:(NSString *)frameworkName;
- (void)_forceEssentialFrameworkNamesToTopOfList:(NSMutableArray *)fwNames;

@end

#pragma mark -

@implementation AKDocSetIndex

#pragma mark -
#pragma mark SQL queries

// Tables we use in the dsidx SQLite database. ZTOKEN is the main table, and ZTOKENMETAINFORMATION
// gives us additional information about tokens.
//
//    ZTOKEN
//        ZTOKENNAME
//        ZLANGUAGE => ZAPILANGUAGE
//        ZTOKENTYPE => ZTOKENTYPE
//        ZMETAINFORMATION => ZTOKENMETAINFORMATION
//
//    ZTOKENMETAINFORMATION
//        ZTOKEN => ZTOKEN
//        ZFILE => ZFILEPATH
//        ZDECLAREDIN => ZHEADER
//        ZRETURNVALUE => ZRETURNVALUE
//        ZANCHOR
//        ZDECLARATION
//        ZDEPRECATIONSUMMARY
//        ZABSTRACT
//
//    These tables are mostly lists of strings, although ZHEADER also has a ZFRAMEWORKNAME column
//
//    ZAPILANGUAGE
//        ZFULLNAME
//
//    ZFILEPATH
//        ZPATH
//
//    ZHEADER
//        ZHEADERPATH
//        ZFRAMEWORKNAME
//
//    ZRETURNVALUE
//        ZABSTRACT
//
//    ZTOKENTYPE
//        ZTYPENAME

// Gets the names of all frameworks in the docset.
static NSString *s_allFrameworkNamesQuery =
    @"select distinct ZFRAMEWORKNAME from ZHEADER order by ZFRAMEWORKNAME";

// Gets the names of all frameworks containing Objective-C classes and protocols.
static NSString *s_objectiveCFrameworkNamesQuery =
    @"select distinct "
        @"header.ZFRAMEWORKNAME "
    @"from "
        @"ZTOKEN token, "
        @"ZTOKENTYPE tokenType, "
        @"ZTOKENMETAINFORMATION tokenMeta, "
        @"ZHEADER header, "
        @"ZAPILANGUAGE language "
    @"where "
        @"token.ZLANGUAGE = language.Z_PK "
        @"and language.ZFULLNAME = 'Objective-C' "
        @"and token.ZTOKENTYPE = tokenType.Z_PK "
        @"and token.ZMETAINFORMATION = tokenMeta.Z_PK "
        @"and tokenMeta.ZDECLAREDIN = header.Z_PK "
        @"and tokenType.ZTYPENAME in ('cl', 'intf') "
    @"order by "
        @"header.ZFRAMEWORKNAME";

// Gets all doc file paths for up to four token types within the specified framework.
static NSString *s_docPathsQueryTemplate =
    @"select distinct "
        @"filePath.ZPATH as docPath "
    @"from "
        @"ZTOKEN token, "
        @"ZTOKENTYPE tokenType, "
        @"ZTOKENMETAINFORMATION tokenMeta, "
        @"ZHEADER header, "
        @"ZFILEPATH filePath "
    @"where "
        @"token.ZTOKENTYPE = tokenType.Z_PK "
        @"and token.ZMETAINFORMATION = tokenMeta.Z_PK "
        @"and tokenMeta.ZFILE = filePath.Z_PK "
        @"and tokenMeta.ZDECLAREDIN = header.Z_PK "
        @"and header.ZFRAMEWORKNAME = ? "
        @"and tokenType.ZTYPENAME in (?, ?, ?, ?)";

// Unfortunately s_docPathsQueryTemplate doesn't get all the doc paths we want, because some rows
// in ZTOKENMETAINFORMATION are missing a ZDECLAREDIN foreign key (to the ZHEADER table), which we
// need to be able to tell what framework a token is in, because ZFRAMEWORKNAME is in ZHEADER.
//
// As a workaround, we make a second query using s_docPathsSecondQueryTemplate, which looks for
// tokens where ZDECLAREDIN is null and the doc path contains the framework name as a component.
// For example, we assume any tokens documented in .../CoreData/... are in the CoreData framework.
// This reasoning isn't perfect, but it does pick up, for example, NSFetchedResultsControllerDelegate,
// thus fixing <https://github.com/aglee/appkido/issues/3>.
//
// Note: the placeholders must be in the same order as in s_docPathsQueryTemplate.
static NSString *s_docPathsSecondQueryTemplate =
    @"select distinct "
        @"filePath.ZPATH as docPath "
    @"from "
        @"ZTOKEN token, "
        @"ZTOKENTYPE tokenType, "
        @"ZTOKENMETAINFORMATION tokenMeta, "
        @"ZFILEPATH filePath "
    @"where "
        @"token.ZTOKENTYPE = tokenType.Z_PK "
        @"and token.ZMETAINFORMATION = tokenMeta.Z_PK "
        @"and tokenMeta.ZFILE = filePath.Z_PK "
        @"and filePath.ZPATH like '%/' || ? || '/%' "
        @"and tokenType.ZTYPENAME in (?, ?, ?, ?)";

// Gets all header file paths for the specified framework.
static NSString *s_headerPathsQueryTemplate =
    @"select distinct "
        @"header.ZHEADERPATH as headerPath "
    @"from ZTOKEN token, "
        @"ZTOKENMETAINFORMATION tokenMeta, "
        @"ZHEADER header "
    @"where "
        @"token.ZMETAINFORMATION = tokenMeta.Z_PK "
        @"and tokenMeta.ZDECLAREDIN = header.Z_PK "
        @"and header.ZFRAMEWORKNAME = ?";


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDocSetPath:(NSString *)docSetPath basePathForHeaders:(NSString *)basePathForHeaders
{
    DIGSLogDebug(@"initWithDocSetPath:basePathForHeaders: -- [%@], [%@]", docSetPath, basePathForHeaders);

    if ((self = [super init]))
    {
        _docSetPath = [docSetPath retain];
        _basePathForHeaders = [basePathForHeaders retain];

        DIGSLogInfo(@"docset index -- [%@]", [self _pathToSqliteFile]);
        
        BOOL isDir;
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self _pathToSqliteFile] isDirectory:&isDir])
        {
            DIGSLogDebug(@"AKDocSetIndex -- There is no docset at [%@]", _docSetPath);
            [self release];
            return nil;
        }
        else if (isDir)
        {
            DIGSLogDebug(@"AKDocSetIndex -- Dsidx path [%@] is a directory, not a file", [self _pathToSqliteFile]);
            [self release];
            return nil;
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:_basePathForHeaders isDirectory:&isDir])
        {
            DIGSLogWarning(@"AKDocSetIndex -- There is no directory [%@]", _basePathForHeaders);
            [self release];
            return nil;
        }
        else if (!isDir)
        {
            DIGSLogDebug(@"AKDocSetIndex -- Header path [%@] is a file, not a directory", _basePathForHeaders);
            [self release];
            return nil;
        }
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_docSetPath release];
    [_basePathForHeaders release];

    [super dealloc];
}


#pragma mark -
#pragma mark Getters and setters

- (NSArray *)selectableFrameworkNames
{
    static NSMutableArray *s_selectableFrameworkNames = nil;

    if (s_selectableFrameworkNames == nil)
    {
#if APPKIDO_FOR_IPHONE
        s_selectableFrameworkNames = [[self _allFrameworkNames] retain];
#else
        s_selectableFrameworkNames = [[self _objectiveCFrameworkNames] retain];

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
    FMResultSet *rs = [sqliteDB executeQuery:s_headerPathsQueryTemplate, frameworkName];

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
    FMResultSet *rs = [sqliteDB executeQuery:s_headerPathsQueryTemplate, frameworkName];

    while ([rs next])
    {
        NSString *headerFilePath = [rs stringForColumnIndex:0];
        NSString *headerDirPath = [headerFilePath stringByDeletingLastPathComponent];

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
    return
        [self
            _docPathsForTokensOfType:@"cl"
            orType:@"intf"
            orType:@"clm"
            orType:@"instm"  // to pick up "XXX Additions Reference"
            forFramework:frameworkName];
}

- (NSArray *)functionsDocPathsForFramework:(NSString *)frameworkName
{
    return
        [self
            _docPathsForTokensOfType:@"func"
            orType:@"macro"
            forFramework:frameworkName];
}

- (NSArray *)globalsDocPathsForFramework:(NSString *)frameworkName
{
    return
        [self
            _docPathsForTokensOfType:@"econst"
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


#pragma mark -
#pragma mark Private methods

- (NSMutableArray *)_allFrameworkNames
{
    return [self _stringArrayFromQuery:s_allFrameworkNamesQuery];
}

- (NSMutableArray *)_objectiveCFrameworkNames
{
    return [self _stringArrayFromQuery:s_objectiveCFrameworkNamesQuery];
}

- (NSMutableArray *)_stringArrayFromQuery:(NSString *)queryString
{
    NSMutableArray *stringArray = [NSMutableArray array];

    // Open the database.
    FMDatabase* sqliteDB = [self _openSQLiteDB];
    if (sqliteDB == nil)
    {
        return nil;
    }

    // Query the database and process the results.
    FMResultSet *rs = [sqliteDB executeQuery:queryString];
    while ([rs next])
    {
        NSString *fwName = [rs stringForColumnIndex:0];
        [stringArray addObject:fwName];
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
    return
        [self
            _docPathsForTokensOfType:tokenType
            orType:nil
            orType:nil
            forFramework:frameworkName];
}

- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType1
    orType:(NSString *)tokenType2
    forFramework:(NSString *)frameworkName
{
    return
        [self
            _docPathsForTokensOfType:tokenType1
            orType:tokenType2
            orType:nil
            forFramework:frameworkName];
}

- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType1
    orType:(NSString *)tokenType2
    orType:(NSString *)tokenType3
    forFramework:(NSString *)frameworkName
{
    return
        [self
            _docPathsForTokensOfType:tokenType1
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
    NSMutableSet *docPaths = [self _docPathsFromQuery:s_docPathsQueryTemplate
                                        withTokenType:tokenType1
                                               orType:tokenType2
                                               orType:tokenType3
                                               orType:tokenType4
                                         forFramework:frameworkName];
    [docPaths unionSet:[self _docPathsFromQuery:s_docPathsSecondQueryTemplate
                                  withTokenType:tokenType1
                                         orType:tokenType2
                                         orType:tokenType3
                                         orType:tokenType4
                                   forFramework:frameworkName]];

    return [docPaths allObjects];
}

- (void)_forceEssentialFrameworkNamesToTopOfList:(NSMutableArray *)fwNames
{
    NSEnumerator *essentialFrameworkNamesEnum = [AKNamesOfEssentialFrameworks reverseObjectEnumerator];
    NSString *essentialFrameworkName;

    while ((essentialFrameworkName = [essentialFrameworkNamesEnum nextObject]))
    {
        if ([fwNames containsObject:essentialFrameworkName])
        {
            [fwNames removeObject:essentialFrameworkName];
            [fwNames insertObject:essentialFrameworkName atIndex:0];
        }
    }
}

@end
