/*
 * AKOldDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKOldDatabase.h"

#import "DIGSLog.h"

#import "AKFrameworkInfo.h"
#import "AKFileUtils.h"

#import "AKObjCHeaderParser.h"
#import "AKCocoaBehaviorDocParser.h"
#import "AKCocoaFunctionsDocParser.h"
#import "AKCocoaGlobalsDocParser.h"


@implementation AKOldDatabase

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithDevToolsPath:(NSString *)devToolsPath
{
    if ((self = [super initWithPlatformName:AKMacOSPlatform]))
    {
        _devToolsPath = [devToolsPath retain];

        [_namesOfAvailableFrameworks release];
        _namesOfAvailableFrameworks = [[NSMutableArray array] retain];

        NSArray *namesOfPossibleFrameworks =
            [[AKFrameworkInfo sharedInstance] allPossibleFrameworkNames];

        NSEnumerator *fwNameEnum = [namesOfPossibleFrameworks objectEnumerator];
        NSString *fwName;

        while ((fwName = [fwNameEnum nextObject]))
        {
            if ([[AKFrameworkInfo sharedInstance] frameworkDirsExist:fwName])
            {
                [_namesOfAvailableFrameworks addObject:fwName];
            }
        }
    }

    return self;
}

- (id)initWithPlatformName:(NSString *)platformName
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_devToolsPath release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKDatabase methods
//-------------------------------------------------------------------------

- (BOOL)frameworkNameIsSelectable:(NSString *)frameworkName
{
    return
        [[AKFrameworkInfo sharedInstance]
            frameworkDirsExist:frameworkName];
}

- (void)loadTokensForFrameworkNamed:(NSString *)fwName
{
    // Parse header files before HTML files, so that later when we parse a
    // "Deprecated Methods" HTML file we can distinguish between instance
    // methods, class methods, and delegate methods by querying the database.
    // We also use header info to distinguish formal protocols from informal
    // ones -- informal ones do not have an associated header.
    // ([agl] Is this a reliable test for informal protocols?)
    DIGSLogDebug(@"---------------------------------------------------");
    DIGSLogDebug(@"Parsing headers for framework %@", fwName);
    DIGSLogDebug(@"---------------------------------------------------");

    NSString *_headerDir =
        [[AKFrameworkInfo sharedInstance] headerDirForFrameworkNamed:fwName];
    DIGSLogDebug(@"parsing headers in %@", _headerDir);
    [AKObjCHeaderParser
        recursivelyParseDirectory:_headerDir
        forFramework:fwName
        inDatabase:self];
    
    // Figure out which directories contain the doc files.
    NSString *_mainDocDir = [[AKFrameworkInfo sharedInstance] docDirForFrameworkNamed:fwName];
    NSString *behaviorsDocDir = _mainDocDir;
    NSString *functionsDocDir = nil;
    NSString *constantsDocDir = nil;
    NSString *datatypesDocDir = nil;

    if ([[[AKFrameworkInfo sharedInstance] frameworkClassNameForFrameworkNamed:fwName]
            isEqualToString:@"AKCocoaFramework22"])
    {
        functionsDocDir =
            [AKFileUtils
                subdirectoryOf:_mainDocDir
                withName:@"Functions"
                orName:@"functions"];
        constantsDocDir = nil;
        datatypesDocDir =
            [AKFileUtils
                subdirectoryOf:_mainDocDir
                withName:@"TypesAndConstants"
                orName:@"typesandconstants"];
    }
    else
    {
        NSString *miscPath =
            [_mainDocDir stringByAppendingPathComponent:@"Miscellaneous"];

        functionsDocDir =
            [AKFileUtils
                subdirectoryOf:miscPath
                withNameEndingWith:@"Functions"];
        constantsDocDir =
            [AKFileUtils
                subdirectoryOf:miscPath
                withNameEndingWith:@"Constants"];
        datatypesDocDir =
            [AKFileUtils
                subdirectoryOf:miscPath
                withNameEndingWith:@"DataTypes"];
    }

    // Parse the doc files in those directories.
    DIGSLogDebug(@"---------------------------------------------------");
    DIGSLogDebug(@"Parsing HTML docs for framework %@", fwName);
    DIGSLogDebug(@"---------------------------------------------------");

    DIGSLogDebug(@"parsing behavior docs for %@", fwName);
    [AKCocoaBehaviorDocParser
        recursivelyParseDirectory:behaviorsDocDir
        forFramework:fwName
        inDatabase:self];

    DIGSLogDebug(@"parsing functions docs for %@", fwName);
    [AKCocoaFunctionsDocParser
        recursivelyParseDirectory:functionsDocDir
        forFramework:fwName
        inDatabase:self];

    DIGSLogDebug(@"parsing constants docs for %@", fwName);
    [AKCocoaGlobalsDocParser
        recursivelyParseDirectory:constantsDocDir
        forFramework:fwName
        inDatabase:self];

    DIGSLogDebug(@"parsing datatypes docs for %@", fwName);
    [AKCocoaGlobalsDocParser
        recursivelyParseDirectory:datatypesDocDir
        forFramework:fwName
        inDatabase:self];
}

@end

