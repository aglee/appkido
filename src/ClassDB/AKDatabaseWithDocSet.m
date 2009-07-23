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

#import "AKObjCHeaderParser.h"
#import "AKCocoaBehaviorDocParser.h"
#import "AKCocoaFunctionsDocParser.h"
#import "AKCocoaGlobalsDocParser.h"


@implementation AKDatabaseWithDocSet


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDocSetIndex:(AKDocSetIndex *)docSetIndex
{
    if ((self = [super init]))
    {
        _docSetIndex = [docSetIndex retain];

        [_namesOfAvailableFrameworks release];  // [agl] think about this
        _namesOfAvailableFrameworks = [[docSetIndex selectableFrameworkNames] copy];
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
    [_docSetIndex release];

    [super dealloc];
}


#pragma mark -
#pragma mark AKDatabase methods

- (BOOL)frameworkNameIsSelectable:(NSString *)frameworkName
{
    return [[_docSetIndex selectableFrameworkNames] containsObject:frameworkName];
}

- (void)loadTokensForFrameworkNamed:(NSString *)frameworkName
{
    // Parse header files before HTML files, so that later when we parse a
    // "Deprecated Methods" HTML file we can distinguish between instance
    // methods, class methods, and delegate methods by querying the database.
    // [agl] FIXME Any way to remove this dependence on parse order?
    DIGSLogDebug(@"---------------------------------------------------");
    DIGSLogDebug(@"Parsing headers for framework %@, in base dir %@", frameworkName, [_docSetIndex basePathForHeaders]);
    DIGSLogDebug(@"---------------------------------------------------");

    // NOTE that we have to parse all headers in each directory, not just
    // headers that the docset index explicitly associates with ZTOKENs.  For
    // example, several DOMxxx classes, such as DOMComment, will be displayed
    // as root classes if I don't parse their headers.  The ideal thing would
    // be to be able to follow #imports, but I'm not being that smart.
    AKFramework *aFramework = [self frameworkWithName:frameworkName];
    NSSet *headerDirs = [_docSetIndex headerDirsForFramework:frameworkName];
    NSEnumerator *headerDirEnum = [headerDirs objectEnumerator];
    NSString *headerDir;
    while ((headerDir = [headerDirEnum nextObject]) != nil)
    {
        [AKObjCHeaderParser recursivelyParseDirectory:headerDir forFramework:aFramework];
    }

    // Parse HTML files.
    NSString *baseDirForDocs = [_docSetIndex baseDirForDocs];

    DIGSLogDebug(@"---------------------------------------------------");
    DIGSLogDebug(@"Parsing HTML docs for framework %@, in base dir %@", frameworkName, baseDirForDocs);
    DIGSLogDebug(@"---------------------------------------------------");

    DIGSLogDebug(@"Parsing behavior docs for framework %@", frameworkName);
    [AKCocoaBehaviorDocParser
        parseFilesInPaths:[_docSetIndex behaviorDocPathsForFramework:frameworkName]
        underBaseDir:baseDirForDocs
        forFramework:aFramework];

    DIGSLogDebug(@"Parsing functions docs for framework %@", frameworkName);
    [AKCocoaFunctionsDocParser
        parseFilesInPaths:[_docSetIndex functionsDocPathsForFramework:frameworkName]
        underBaseDir:baseDirForDocs
        forFramework:aFramework];

    DIGSLogDebug(@"Parsing globals docs for framework %@", frameworkName);
    [AKCocoaGlobalsDocParser
        parseFilesInPaths:[_docSetIndex globalsDocPathsForFramework:frameworkName]
        underBaseDir:baseDirForDocs
        forFramework:aFramework];
}

@end

