/*
 * AKDocSetBasedFramework.m
 *
 * Created by Andy Lee on 1/21/08.
 * Copyright (c) 2008 Andy Lee. All rights reserved.
 */

#import "AKDocSetBasedFramework.h"

#import <DIGSLog.h>

#import "AKFileUtils.h"
#import "AKDocSetIndex.h"
#import "AKDatabase.h"
#import "AKObjCHeaderParser.h"
#import "AKCocoaBehaviorDocParser.h"
#import "AKCocoaFunctionsDocParser.h"
#import "AKCocoaGlobalsDocParser.h"


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@interface AKDocSetBasedFramework (Private)
- (void)_populateDatabase:(AKDatabase *)db
    fromDocSetIndex:(AKDocSetIndex *)docSetIndex;
- (void)_useParserClass:(Class)parserClass
    toParseFilesInPaths:(NSArray *)docPaths
    fromDocSetIndex:(AKDocSetIndex *)docSetIndex
    intoDatabase:(AKDatabase *)db;
@end


@implementation AKDocSetBasedFramework

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithName:(NSString *)fwName
    docSetIndex:(AKDocSetIndex *)docSetIndex
{
    if ((self = [super initWithName:fwName]))
    {
        _docSetIndex = [docSetIndex retain];
    }

    return self;
}

- (id)initWithName:(NSString *)fwName
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
// AKFramework methods
//-------------------------------------------------------------------------

- (void)populateDatabase:(AKDatabase *)db
{
    [self _populateDatabase:db fromDocSetIndex:_docSetIndex];
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKDocSetBasedFramework (Private)

- (void)_populateDatabase:(AKDatabase *)db
    fromDocSetIndex:(AKDocSetIndex *)docSetIndex
{
    NSString *fwName = [self frameworkName];

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
    DIGSLogDebug(@"Parsing headers for framework %@", fwName);
    NSSet *headerDirs = [docSetIndex headerDirsForFramework:fwName];
    NSEnumerator *dirEnum = [headerDirs objectEnumerator];
    NSString *headerDir;
    while ((headerDir = [dirEnum nextObject]) != nil)
    {
        AKObjCHeaderParser *headerParser =  // no autorelease
            [[AKObjCHeaderParser alloc]
                initWithDatabase:db frameworkName:_frameworkName];

        [headerParser processDirectory:headerDir recursively:YES];
        [headerParser release];  // release here
    }

    // Parse HTML files.
    DIGSLogDebug(@"Parsing docs for framework %@", fwName);
    [self
        _useParserClass:[AKCocoaBehaviorDocParser class]
        toParseFilesInPaths:[docSetIndex behaviorDocPathsForFramework:fwName]
        fromDocSetIndex:docSetIndex
        intoDatabase:db];
    [self
        _useParserClass:[AKCocoaFunctionsDocParser class]
        toParseFilesInPaths:[docSetIndex functionsDocPathsForFramework:fwName]
        fromDocSetIndex:docSetIndex
        intoDatabase:db];
    [self
        _useParserClass:[AKCocoaGlobalsDocParser class]
        toParseFilesInPaths:[docSetIndex globalsDocPathsForFramework:fwName]
        fromDocSetIndex:docSetIndex
        intoDatabase:db];
}

- (void)_useParserClass:(Class)parserClass
    toParseFilesInPaths:(NSArray *)docPaths
    fromDocSetIndex:(AKDocSetIndex *)docSetIndex
    intoDatabase:(AKDatabase *)db
{
    int numDocs = [docPaths count];
    int i;
    for (i = 0; i < numDocs; i++)
    {
        NSString *docPath =
            [[docSetIndex baseDirForDocPaths]
                stringByAppendingPathComponent:[docPaths objectAtIndex:i]];

        id parser =
            [[parserClass alloc]  // no autorelease
                initWithDatabase:db
                frameworkName:_frameworkName];

        [parser processFile:docPath];
        [parser release];  // release here
    }
}

@end
