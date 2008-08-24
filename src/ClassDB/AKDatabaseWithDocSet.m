//
//  AKDatabaseWithDocSet.m
//  AppKiDo
//
//  Created by Andy Lee on 7/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDatabaseWithDocSet.h"

#import "DIGSLog.h"

#import "AKDocSetIndex.h"

#import "AKFileSection.h"

#import "AKBehaviorNode.h"
#import "AKClassNode.h"
#import "AKGlobalsNode.h"
#import "AKGroupNode.h"

#import "AKObjCHeaderParser.h"
#import "AKCocoaBehaviorDocParser.h"
#import "AKCocoaFunctionsDocParser.h"
#import "AKCocoaGlobalsDocParser.h"


@implementation AKDatabaseWithDocSet

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithPlatformName:(NSString *)platformName
    docSetIndex:(AKDocSetIndex *)docSetIndex
{
    if ((self = [super initWithPlatformName:platformName]))
    {
        _docSetIndex = [docSetIndex retain];

        [_namesOfAvailableFrameworks release];
        _namesOfAvailableFrameworks = [[docSetIndex objectiveCFrameworkNames] copy];
    }

    return self;
}

- (id)initWithPlatformName:(NSString *)platformName
{
    DIGSLogNondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_docSetIndex release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKDatabase methods
//-------------------------------------------------------------------------

- (void)loadTokensForFrameworks:(NSArray *)frameworkNames
{
    if (frameworkNames == nil)
    {
        frameworkNames = [_docSetIndex objectiveCFrameworkNames];
    }

    [super loadTokensForFrameworks:frameworkNames];
}

- (void)loadTokensForFrameworkNamed:(NSString *)fwName
{
    // Parse header files before HTML files, so that later when we parse a
    // "Deprecated Methods" HTML file we can distinguish between instance
    // methods, class methods, and delegate methods by querying the database.
// Note that we have to parse all headers in the dir, not just headers
// directly associated with ZTOKENs, because there may be things declared
// in headers that are needed but not associated with any ZTOKEN.  ([agl] The
// example that drives this was the DOMxxx classes, like DOMComment, which
// ended up as root classes in AppKiDo because apparently there is some base
// class declared in a header I wasn't parsing.  *But* those classes are kind
// of weird -- they have no documentation -- so maybe I shouldn't be displaying
// them at all and should go back to the logic where I parsed an array of
// header file paths rather than header dirs.)
    DIGSLogDebug(@"---------------------------------------------------");
    DIGSLogDebug(@"Parsing headers for framework %@", fwName);
    DIGSLogDebug(@"---------------------------------------------------");

    NSSet *headerDirs = [_docSetIndex headerDirsForFramework:fwName];
    NSEnumerator *headerDirEnum = [headerDirs objectEnumerator];
    NSString *headerDir;
    while ((headerDir = [headerDirEnum nextObject]) != nil)
    {
        [AKObjCHeaderParser
            recursivelyParseDirectory:headerDir
            forFramework:fwName
            inDatabase:self];
    }

    // Parse HTML files.
    DIGSLogDebug(@"---------------------------------------------------");
    DIGSLogDebug(@"Parsing HTML docs for framework %@", fwName);
    DIGSLogDebug(@"---------------------------------------------------");

    NSString *baseDir = [_docSetIndex baseDirForDocPaths];

    DIGSLogDebug(@"Parsing behavior docs for framework %@", fwName);
    [AKCocoaBehaviorDocParser
        parseFilesInPaths:[_docSetIndex behaviorDocPathsForFramework:fwName]
        underBaseDir:baseDir
        forFramework:fwName
        inDatabase:self];

    DIGSLogDebug(@"Parsing functions docs for framework %@", fwName);
    [AKCocoaFunctionsDocParser
        parseFilesInPaths:[_docSetIndex functionsDocPathsForFramework:fwName]
        underBaseDir:baseDir
        forFramework:fwName
        inDatabase:self];

    DIGSLogDebug(@"Parsing globals docs for framework %@", fwName);
    [AKCocoaGlobalsDocParser
        parseFilesInPaths:[_docSetIndex globalsDocPathsForFramework:fwName]
        underBaseDir:baseDir
        forFramework:fwName
        inDatabase:self];
}

@end

