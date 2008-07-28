/*
 *  AKDocSetIndex.m
 *
 *  Created by Andy Lee on 1/6/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import "AKDocSetIndex.h"

#import <DIGSLog.h>
#import "FMDatabase.h"
#import "AKFrameworkConstants.h"
#import "AKTextUtils.h"
#import "AKFileUtils.h"


@interface AKDocSetIndex (Private)

- (NSString *)_resourcesPath;
- (NSString *)_dsidxPath;
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
- (void)_forceFrameworkNames:(NSArray *)specialFwNames
    toTopOfList:(NSMutableArray *)fwNames;

@end


@implementation AKDocSetIndex

//-------------------------------------------------------------------------
// SQL queries
//-------------------------------------------------------------------------

static NSString *s_objectiveCFrameworkNamesQuery =
    @"select distinct header.ZFRAMEWORKNAME from ZTOKEN token, ZTOKENTYPE tokenType, ZTOKENMETAINFORMATION tokenMeta, ZHEADER header, ZAPILANGUAGE language where token.ZLANGUAGE = language.Z_PK and language.ZFULLNAME = 'Objective-C' and token.ZTOKENTYPE = tokenType.Z_PK and token.ZMETAINFORMATION = tokenMeta.Z_PK and tokenMeta.ZDECLAREDIN = header.Z_PK and tokenType.ZTYPENAME in ('cl', 'intf') order by header.ZFRAMEWORKNAME";

/*!
 * Returns a single column containing distinct doc paths for up to three token
 * types within the specified framework.
 */
static NSString *s_docPathsQueryTemplate =
    @"select distinct filePath.ZPATH as docPath from ZTOKEN token, ZTOKENTYPE tokenType, ZTOKENMETAINFORMATION tokenMeta, ZHEADER header, ZFILEPATH filePath where token.ZTOKENTYPE = tokenType.Z_PK and token.ZMETAINFORMATION = tokenMeta.Z_PK and tokenMeta.ZDECLAREDIN = header.Z_PK and tokenMeta.ZFILE = filePath.Z_PK and (tokenType.ZTYPENAME = ? or tokenType.ZTYPENAME = ? or tokenType.ZTYPENAME = ?) and header.ZFRAMEWORKNAME = ?";

static NSString *s_headerPathsQueryTemplate =
    @"select distinct header.ZHEADERPATH as headerPath from ZTOKEN token, ZTOKENMETAINFORMATION tokenMeta, ZHEADER header where token.ZMETAINFORMATION = tokenMeta.Z_PK and tokenMeta.ZDECLAREDIN = header.Z_PK and header.ZFRAMEWORKNAME = ?";

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithDocSetPath:(NSString *)docSetPath
    basePathForHeaders:(NSString *)basePathForHeaders
{
    if ((self = [super init]))
    {
        _docSetPath = [docSetPath retain];
        _basePathForHeaders = [basePathForHeaders retain];

        if (![[NSFileManager defaultManager] fileExistsAtPath:[self _dsidxPath]])
        {
            DIGSLogWarning(@"AKDocSetIndex -- There is no docset at [%@]", docSetPath);
            [self release];
            return nil;
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:_basePathForHeaders])
        {
            DIGSLogWarning(@"AKDocSetIndex -- There is no directory [%@]", _basePathForHeaders);
            [self release];
            return nil;
        }
    }

    return self;
}

- (id)init
{
    DIGSLogNondesignatedInitializer();
    [self dealloc];
    return nil;
}

- (void)dealloc
{
    [_docSetPath release];
    [_basePathForHeaders release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)baseDirForDocPaths
{
    return [[self _resourcesPath] stringByAppendingPathComponent: @"Documents"];
}

- (NSArray *)objectiveCFrameworkNames
{
    // Open the database.
    FMDatabase* db = [self _openSQLiteDB];
    if (db == nil)
    {
        return nil;
    }

    // Do the query and process the results.
    NSMutableArray *frameworkNames = [NSMutableArray array];
    FMResultSet *rs =
        [db executeQuery:s_objectiveCFrameworkNamesQuery];

    while ([rs next])
    {
        NSString *fwName = [rs stringForColumnIndex:0];
        if (![fwName isEqualToString:@"Carbon"])  // [agl] REMOVE why is carbon returned by the query?
        {
            [frameworkNames addObject:fwName];
        }
    }
    [rs close];  

    // Close the database.
    [db close];

    // Force special framework names to the top of the list.  Order is
    // important because frameworks will be loaded in this order, and the first
    // framework seen for a node is the node's primary framework.
    [self
        _forceFrameworkNames:
            [NSArray arrayWithObjects:
                AKFoundationFrameworkName,
                AKAppKitFrameworkName,
                AKUIKitFrameworkName,
                AKCoreDataFrameworkName,
                AKCoreImageFrameworkName,
                AKQuartzCoreFrameworkName,
                nil]
        toTopOfList:frameworkNames];

    return frameworkNames;
}

- (NSSet *)headerDirsForFramework:(NSString *)frameworkName
{
    // Open the database.
    FMDatabase* db = [self _openSQLiteDB];
    if (db == nil)
    {
        return nil;
    }

    // Do the query and process the results.
    NSMutableSet *headerDirs = [NSMutableSet set];
    FMResultSet *rs =
        [db executeQuery:s_headerPathsQueryTemplate, frameworkName];

    while ([rs next])
    {
        NSString *headerFilePath = [rs stringForColumnIndex:0];
        NSString *headerDirPath =
            [headerFilePath stringByDeletingLastPathComponent];

        if (_basePathForHeaders)
        {
            headerDirPath =
                [_basePathForHeaders
                    stringByAppendingPathComponent:headerDirPath];
        }
        
        [headerDirs addObject:headerDirPath];
    }
    [rs close];  

    // Close the database.
    [db close];

    return headerDirs;
}

- (NSArray *)behaviorDocPathsForFramework:(NSString *)frameworkName
{
    return
        [self
            _docPathsForTokensOfType:@"instm"  // note instm, not cl, to pick up "XXX Additions Reference"
            orType:@"clm"
            orType:@"intfm"
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
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKDocSetIndex (Private)

- (NSString *)_resourcesPath
{
    return [_docSetPath stringByAppendingPathComponent:@"Contents/Resources"];
}

- (NSString *)_dsidxPath
{
    return [[self _resourcesPath] stringByAppendingPathComponent:@"docSet.dsidx"];
}

- (FMDatabase *)_openSQLiteDB
{
    FMDatabase* db = [FMDatabase databaseWithPath:[self _dsidxPath]];

    if (![db open])
    {
        DIGSLogError(@"%@", @"Could not open db.");
        return nil;
    }

    return db;
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

- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType
    orType:(NSString *)tokenType2
    forFramework:(NSString *)frameworkName
{
    return
        [self
            _docPathsForTokensOfType:tokenType
            orType:tokenType2
            orType:nil
            forFramework:frameworkName];
}

- (NSArray *)_docPathsForTokensOfType:(NSString *)tokenType
    orType:(NSString *)tokenType2
    orType:(NSString *)tokenType3
    forFramework:(NSString *)frameworkName
{
    // Open the database.
    FMDatabase* db = [self _openSQLiteDB];
    if (db == nil)
    {
        return nil;
    }

    // Do the query and process the results.
    if (tokenType2 == nil)
    {
        tokenType2 = tokenType;
    }

    if (tokenType3 == nil)
    {
        tokenType3 = tokenType;
    }

    NSMutableArray *docPaths = [NSMutableArray array];
    FMResultSet *rs =
        [db executeQuery:s_docPathsQueryTemplate,
            tokenType,
            tokenType2,
            tokenType3,
            frameworkName];

    while ([rs next])
    {
        [docPaths addObject:[rs stringForColumnIndex:0]];
    }
    [rs close];  

    // Close the database.
    [db close];

    return docPaths;
}

- (void)_forceFrameworkNames:(NSArray *)specialFwNames
    toTopOfList:(NSMutableArray *)fwNames
{
    NSUInteger numSpecialNames = [specialFwNames count];
    int i;

    for (i = numSpecialNames - 1; i >= 0; i--)
    {
        NSString *specialName = [specialFwNames objectAtIndex:i];

        if ([fwNames containsObject:specialName])
        {
            [fwNames removeObject:specialName];
            [fwNames insertObject:specialName atIndex:0];
        }
    }
}

@end
