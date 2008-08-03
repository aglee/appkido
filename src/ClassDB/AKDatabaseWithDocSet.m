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


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@interface AKDatabaseWithDocSet (Private)
- (void)_useParserClass:(Class)parserClass
    toParseFilesInPaths:(NSArray *)docPaths
    forFramework:(NSString *)fwName;
- (void)_buildMasterIndex;
@end


@implementation AKDatabaseWithDocSet

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithDocSetIndex:(AKDocSetIndex *)docSetIndex
{
    if ((self = [super init]))
    {
        _docSetIndex = [docSetIndex retain];

        [_namesOfAvailableFrameworks release];
        _namesOfAvailableFrameworks = [[docSetIndex objectiveCFrameworkNames] copy];
    }

    return self;
}

- (id)init
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
    [super loadTokensForFrameworks:frameworkNames];

    // Now that all nodes have been added to the database, index them.
    [self _buildMasterIndex];
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

    DIGSLogDebug(@"Parsing behavior docs for framework %@", fwName);
    [self
        _useParserClass:[AKCocoaBehaviorDocParser class]
        toParseFilesInPaths:[_docSetIndex behaviorDocPathsForFramework:fwName]
        forFramework:fwName];

    DIGSLogDebug(@"Parsing functions docs for framework %@", fwName);
    [self
        _useParserClass:[AKCocoaFunctionsDocParser class]
        toParseFilesInPaths:[_docSetIndex functionsDocPathsForFramework:fwName]
        forFramework:fwName];

    DIGSLogDebug(@"Parsing globals docs for framework %@", fwName);
    [self
        _useParserClass:[AKCocoaGlobalsDocParser class]
        toParseFilesInPaths:[_docSetIndex globalsDocPathsForFramework:fwName]
        forFramework:fwName];
}

@end


@implementation AKDatabaseWithDocSet (Private)

- (void)_useParserClass:(Class)parserClass
    toParseFilesInPaths:(NSArray *)docPaths
    forFramework:(NSString *)fwName
{
    int numDocs = [docPaths count];
    int i;
    for (i = 0; i < numDocs; i++)
    {
        NSString *docPath =
            [[_docSetIndex baseDirForDocPaths]
                stringByAppendingPathComponent:[docPaths objectAtIndex:i]];

        id parser =
            [[parserClass alloc]  // no autorelease
                initWithDatabase:self
                frameworkName:fwName];

        [parser processFile:docPath];
        [parser release];  // release here
    }
}

- (void)_addNodeToMasterIndex:(id)node
{
    // We only want documented nodes in the master index.
    if ([node nodeDocumentation] == nil)
    {
        return;
    }

    // Remember what framework this doc file is for.
    NSString *htmlPath = [[node nodeDocumentation] filePath];
    [_frameworkNamesByHTMLPath
        setObject:[node owningFramework]
        forKey:htmlPath];

    // Register the node under its own name.
    NSMutableDictionary *nodesByTokenName =
        [_nodesByHTMLPathAndTokenName objectForKey:htmlPath];

    if (nodesByTokenName == nil)
    {
        nodesByTokenName = [NSMutableDictionary dictionary];
        [_nodesByHTMLPathAndTokenName
            setObject:nodesByTokenName
            forKey:htmlPath];
    }

    [nodesByTokenName setObject:node forKey:[node nodeName]];

    // Register the node under the names of any other tokens it covers.
    if ([node isKindOfClass:[AKGlobalsNode class]])
    {
        NSEnumerator *globalsEnum =
            [[node namesOfGlobals] objectEnumerator];
        NSString *nameOfGlobal;

        while ((nameOfGlobal = [globalsEnum nextObject]))
        {
            [nodesByTokenName setObject:node forKey:nameOfGlobal];
        }
    }
}

- (void)_addToMasterIndexFromCollection:(id)nodeCollection
{
    NSEnumerator *collectionEnum = [nodeCollection objectEnumerator];
    id element;

    while ((element = [collectionEnum nextObject]))
    {
        // [agl] TODO -- Should I be bothered by all the -isKindOfClass: calls?
        if ([element isKindOfClass:[NSArray class]])
        {
            [self _addToMasterIndexFromCollection:element];
        }
        else if ([element isKindOfClass:[AKGroupNode class]])
        {
            [self _addToMasterIndexFromCollection:[element subnodes]];
        }
        else if ([element isKindOfClass:[AKDatabaseNode class]])
        {
            // Add the node itself to the master index.
            [self _addNodeToMasterIndex:element];

            // If the node is a behavior node, add its member nodes.
            if ([element isKindOfClass:[AKBehaviorNode class]])
            {
                [self _addToMasterIndexFromCollection:[element documentedProperties]];
                [self _addToMasterIndexFromCollection:[element documentedClassMethods]];
                [self _addToMasterIndexFromCollection:[element documentedInstanceMethods]];

                if ([element isClassNode])
                {
                    [self _addToMasterIndexFromCollection:[element documentedDelegateMethods]];
                    [self _addToMasterIndexFromCollection:[element documentedNotifications]];
                }
            }
        }
        else
        {
            DIGSLogWarning(@"unexpected class %@ for node collection",
                [nodeCollection class]);
        }
    }
}

- (void)_buildMasterIndex
{
    [_nodesByHTMLPathAndTokenName removeAllObjects];
    [_frameworkNamesByHTMLPath removeAllObjects];

    [self _addToMasterIndexFromCollection:_classNodesByName];
    [self _addToMasterIndexFromCollection:_protocolNodesByName];
    [self _addToMasterIndexFromCollection:_functionsGroupListsByFramework];
    [self _addToMasterIndexFromCollection:_globalsGroupListsByFramework];
}

@end
