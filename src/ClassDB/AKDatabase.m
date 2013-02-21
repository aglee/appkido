/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase.h"

#import "DIGSLog.h"

#import "AKFrameworkConstants.h"
#import "AKDevToolsUtils.h"
#import "AKPrefUtils.h"

#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKGroupNode.h"

#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"
#import "AKDocSetIndex.h"

#import "AKObjCHeaderParser.h"
#import "AKCocoaBehaviorDocParser.h"
#import "AKCocoaFunctionsDocParser.h"
#import "AKCocoaGlobalsDocParser.h"


@implementation AKDatabase
{
    id <AKDatabaseDelegate> _delegate;  // NOT retained; see category NSObject+AKDatabaseDelegate

    AKDocSetIndex *_docSetIndex;

    // --- Frameworks ---

    NSMutableDictionary *_frameworksByName;  // (NSString) -> (AKFramework)

    // There are constants in AKFrameworkConstants.h for the names of some frameworks
    // that need to be treated specially.
    NSMutableArray *_frameworkNames;  // frameworks that have been loaded
    NSMutableArray *_namesOfAvailableFrameworks;  // frameworks that the user could choose to load

    // --- Classes ---

    // (class name) -> (AKClassNode)
    NSMutableDictionary *_classNodesByName;

    // (framework name) -> (NSArray of AKClassNode)
    NSMutableDictionary *_classListsByFramework;

    // --- Protocols ---

    // (protocol name) -> (AKProtocolNodes)
    NSMutableDictionary *_protocolNodesByName;

    // (framework name) -> (NSArray of AKProtocolNode)
    NSMutableDictionary *_protocolListsByFramework;

    // --- Functions ---

    // (framework name) -> (NSArray of AKGroupNode)
    NSMutableDictionary *_functionsGroupListsByFramework;

    // (framework name) -> ((group name) -> AKGroupNode)
    NSMutableDictionary *_functionsGroupsByFrameworkAndGroup;

    // --- Globals ---

    // (framework name) -> (NSArray of AKGroupNode)
    NSMutableDictionary *_globalsGroupListsByFramework;

    // (framework name) -> ((group name) -> AKGroupNode)
    NSMutableDictionary *_globalsGroupsByFrameworkAndGroup;

    // --- Hyperlink support ---

    // (path to HTML file) -> (name of framework)
    NSMutableDictionary *_frameworkNamesByHTMLPath;

    // (path to HTML file) -> (AKClassNode)
    NSMutableDictionary *_classNodesByHTMLPath;

    // (path to HTML file) -> (AKProtocolNode)
    NSMutableDictionary *_protocolNodesByHTMLPath;

    // (path to HTML file) -> (root AKFileSection for that file)
    // See AKDocParser for an explanation of root sections.
    NSMutableDictionary *_rootSectionsByHTMLPath;

    // Keys are anchor strings.  Each value is a dictionary whose keys are
    // paths to HTML files and whose values are NSNumbers containing the
    // byte offset of that anchor within that file.
    //
    // See the comment for -offsetOfAnchorString:inHTMLFile: to see what
    // is meant by "anchor strings."
    NSMutableDictionary *_offsetsOfAnchorStringsInHTMLFiles;
}


#pragma mark -
#pragma mark Factory methods

+ (id)databaseForMacPlatformWithErrorStrings:(NSMutableArray *)errorStrings
{
    AKDatabase *dbToReturn = nil;
    NSString *devToolsPath = [AKPrefUtils devToolsPathPref];

    if (![AKDevTools looksLikeValidDevToolsPath:devToolsPath errorStrings:errorStrings])
    {
        return nil;
    }

    AKDevTools *devTools = [AKMacDevTools devToolsWithPath:devToolsPath];
    AKDocSetIndex *docSetIndex = [self _docSetIndexForDevTools:devTools
                                                  errorStrings:errorStrings];
    if (docSetIndex == nil)
    {
        return nil;
    }

    dbToReturn = [[self alloc] initWithDocSetIndex:docSetIndex];

    // For a new user of AppKiDo for Mac OS, only load the "essential"
    // frameworks by default and leave it up to them to add more as needed.
    // It would be nice to simply provide everything, but until we cut down
    // the amount of startup time used by parsing, that will take too long.
    if ([AKPrefUtils selectedFrameworkNamesPref] == nil)
    {
        [AKPrefUtils setSelectedFrameworkNamesPref:AKNamesOfEssentialFrameworks];
    }

    return dbToReturn;
}

+ (id)databaseForIPhonePlatformWithErrorStrings:(NSMutableArray *)errorStrings
{
    AKDatabase *dbToReturn = nil;
    NSString *devToolsPath = [AKPrefUtils devToolsPathPref];

    if (![AKDevTools looksLikeValidDevToolsPath:devToolsPath errorStrings:errorStrings])
    {
        return nil;
    }
    
    AKDevTools *devTools = [AKIPhoneDevTools devToolsWithPath:devToolsPath];
    AKDocSetIndex *docSetIndex = [self _docSetIndexForDevTools:devTools
                                                  errorStrings:errorStrings];
    if (docSetIndex == nil)
    {
        return nil;
    }
    
    dbToReturn = [[self alloc] initWithDocSetIndex:docSetIndex];

    // Assume a new user of AppKiDo-for-iPhone is going to want all possible
    // frameworks in the iPhone SDK by default, and will deselect whichever
    // ones they don't want.  The docset is small enough that we can do this.  [agl] Still?
    if ([AKPrefUtils selectedFrameworkNamesPref] == nil)
    {
        [AKPrefUtils setSelectedFrameworkNamesPref:[docSetIndex selectableFrameworkNames]];
    }

    return dbToReturn;
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDocSetIndex:(AKDocSetIndex *)docSetIndex
{
    if ((self = [super init]))
    {
        _docSetIndex = docSetIndex;

        _frameworksByName = [[NSMutableDictionary alloc] init];
        _frameworkNames = [[NSMutableArray alloc] init];
        _namesOfAvailableFrameworks = [[docSetIndex selectableFrameworkNames] copy];

        _classNodesByName = [[NSMutableDictionary alloc] init];
        _classListsByFramework = [[NSMutableDictionary alloc] init];

        _protocolNodesByName = [[NSMutableDictionary alloc] init];
        _protocolListsByFramework = [[NSMutableDictionary alloc] init];

        _functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _classNodesByHTMLPath = [[NSMutableDictionary alloc] init];
        _protocolNodesByHTMLPath = [[NSMutableDictionary alloc] init];
        _rootSectionsByHTMLPath = [[NSMutableDictionary alloc] init];
        _offsetsOfAnchorStringsInHTMLFiles = [[NSMutableDictionary alloc] initWithCapacity:30000];

        _frameworkNamesByHTMLPath = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark Populating the database

- (BOOL)frameworkNameIsSelectable:(NSString *)frameworkName
{
    return [[_docSetIndex selectableFrameworkNames] containsObject:frameworkName];
}

- (void)loadTokensForFrameworks:(NSArray *)frameworkNames
{
    if (frameworkNames == nil)
    {
        frameworkNames = AKNamesOfEssentialFrameworks;
    }

    for (NSString *fwName in frameworkNames)
    {
        if ([self frameworkNameIsSelectable:fwName])
        {
            @autoreleasepool
            {
                DIGSLogDebug(@"===================================================");
                DIGSLogDebug(@"Loading tokens for framework %@", fwName);
                DIGSLogDebug(@"===================================================");

                if ([(id)_delegate respondsToSelector:@selector(database:willLoadTokensForFramework:)])
                {
                    [_delegate database:self willLoadTokensForFramework:fwName];
                }

                [self _loadTokensForFrameworkNamed:fwName];
            }
        }
    }
}


#pragma mark -
#pragma mark Getters and setters

- (AKDocSetIndex *)docSetIndex
{
    return _docSetIndex;
}

- (void)setDelegate:(id <AKDatabaseDelegate>)delegate
{
    _delegate = delegate;  // [agl] note this is NOT retained
}


#pragma mark -
#pragma mark Getters and setters -- frameworks

- (AKFramework *)frameworkWithName:(NSString *)frameworkName
{
    AKFramework *aFramework = [_frameworksByName objectForKey:frameworkName];

    if (aFramework == nil)
    {
        aFramework = [[AKFramework alloc] init];
        [aFramework setOwningDatabase:self];
        [aFramework setFrameworkName:frameworkName];

        [_frameworksByName setObject:aFramework forKey:frameworkName];
    }

    return aFramework;
}

- (NSArray *)frameworkNames
{
    return _frameworkNames;
}

- (NSArray *)sortedFrameworkNames
{
    return [_frameworkNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName
{
    return [_frameworkNames containsObject:frameworkName];
}

- (NSArray *)namesOfAvailableFrameworks
{
    return _namesOfAvailableFrameworks;
}


#pragma mark -
#pragma mark Getters and setters -- classes

- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName
{
    return [_classListsByFramework objectForKey:frameworkName];
}

- (NSArray *)rootClasses
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKClassNode *classNode in [self allClasses])
    {
        if ([classNode parentClass] == nil)
        {
            [result addObject:classNode];
        }
    }

    return result;
}

- (NSArray *)allClasses
{
    return [_classNodesByName allValues];
}

- (AKClassNode *)classWithName:(NSString *)className
{
    return [_classNodesByName objectForKey:className];
}

- (void)addClassNode:(AKClassNode *)classNode
{
    // Do nothing if we already have a class with the same name.
    NSString *className = [classNode nodeName];
    if ([_classNodesByName objectForKey:className])
    {
        DIGSLogDebug(@"Trying to add class [%@] again", className);
        return;
    }

    // Add the class to our lookup by class name.
    [_classNodesByName setObject:classNode forKey:className];

    // Add the class to our lookup by framework name.
    NSString *frameworkName = [[classNode owningFramework] frameworkName];
    NSMutableArray *classNodes = [_classListsByFramework objectForKey:frameworkName];

    if (classNodes == nil)
    {
        classNodes = [NSMutableArray array];
        [_classListsByFramework setObject:classNodes forKey:frameworkName];
    }

    [classNodes addObject:classNode];

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:frameworkName];
}


#pragma mark -
#pragma mark Getters and setters -- protocols

- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKProtocolNode *protocolNode in [self _allProtocolsForFrameworkNamed:frameworkName])
    {
        if (![protocolNode isInformal])
        {
            [result addObject:protocolNode];
        }
    }

    return result;
}

- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKProtocolNode *protocolNode in [self _allProtocolsForFrameworkNamed:frameworkName])
    {
        if ([protocolNode isInformal])
        {
            [result addObject:protocolNode];
        }
    }

    return result;
}

- (NSArray *)allProtocols
{
    return [_protocolNodesByName allValues];
}

- (AKProtocolNode *)protocolWithName:(NSString *)name
{
    return [_protocolNodesByName objectForKey:name];
}

- (void)addProtocolNode:(AKProtocolNode *)protocolNode
{
    // Do nothing if we already have a protocol with the same name.
    NSString *protocolName = [protocolNode nodeName];
    if ([_protocolNodesByName objectForKey:protocolName])
    {
        DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
        return;
    }

    // Add the protocol to our lookup by protocol name.
    [_protocolNodesByName setObject:protocolNode forKey:protocolName];

    // Add the class to our lookup by framework name.
    NSString *frameworkName = [[protocolNode owningFramework] frameworkName];
    NSMutableArray *protocolNodes = [_protocolListsByFramework objectForKey:frameworkName];

    if (protocolNodes == nil)
    {
        protocolNodes = [NSMutableArray array];
        [_protocolListsByFramework setObject:protocolNodes forKey:frameworkName];
    }

    [protocolNodes addObject:protocolNode];

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:frameworkName];
}


#pragma mark -
#pragma mark Getters and setters -- functions

- (NSInteger)numberOfFunctionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return [[_functionsGroupListsByFramework objectForKey:frameworkName] count];
}

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return [_functionsGroupListsByFramework objectForKey:frameworkName];
}

- (AKGroupNode *)functionsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName
{
    return [[_functionsGroupsByFrameworkAndGroup objectForKey:frameworkName] objectForKey:groupName];
}

- (void)addFunctionsGroup:(AKGroupNode *)groupNode
{
    NSString *frameworkName = [[groupNode owningFramework] frameworkName];

    // See if we have any functions groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName = [_functionsGroupsByFrameworkAndGroup objectForKey:frameworkName];

    if (groupsByName)
    {
        groupList = [_functionsGroupListsByFramework objectForKey:frameworkName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        [_functionsGroupsByFrameworkAndGroup setObject:groupsByName forKey:frameworkName];

        groupList = [NSMutableArray array];
        [_functionsGroupListsByFramework setObject:groupList forKey:frameworkName];
    }

    // Add the functions group if it isn't already in the framework.
    NSString *groupName = [groupNode nodeName];

    if ([groupsByName objectForKey:groupName])
    {
        DIGSLogWarning(@"Trying to add functions group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupNode];
        [groupsByName setObject:groupNode forKey:[groupNode nodeName]];
    }

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:frameworkName];
}

- (AKGroupNode *)functionsGroupContainingFunctionNamed:(NSString *)functionName
                                      inFrameworkNamed:(NSString *)frameworkName
{
    // Get the functions groups for the given framework.
    NSMutableArray *groupList = [_functionsGroupListsByFramework objectForKey:frameworkName];
    if (groupList == nil)
    {
        return nil;
    }

    // Check each functions group to see if it contains the given function.
    for (AKGroupNode *groupNode in groupList)
    {
        if ([groupNode subnodeWithName:functionName] != nil)
        {
            return groupNode;
        }
    }

    // If we got this far, we couldn't find the function.
    return nil;
}


#pragma mark -
#pragma mark Getters and setters -- globals

- (NSInteger)numberOfGlobalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return [[_globalsGroupListsByFramework objectForKey:frameworkName] count];
}

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return [_globalsGroupListsByFramework objectForKey:frameworkName];
}

- (AKGroupNode *)globalsGroupNamed:(NSString *)groupName
                  inFrameworkNamed:(NSString *)frameworkName
{
    return [[_globalsGroupsByFrameworkAndGroup objectForKey:frameworkName] objectForKey:groupName];
}

- (void)addGlobalsGroup:(AKGroupNode *)groupNode
{
    NSString *frameworkName = [[groupNode owningFramework] frameworkName];

    // See if we have any globals groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName = [_globalsGroupsByFrameworkAndGroup objectForKey:frameworkName];

    if (groupsByName)
    {
        groupList = [_globalsGroupListsByFramework objectForKey:frameworkName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        [_globalsGroupsByFrameworkAndGroup setObject:groupsByName forKey:frameworkName];

        groupList = [NSMutableArray array];
        [_globalsGroupListsByFramework setObject:groupList forKey:frameworkName];
    }

    // Add the globals group if it isn't already in the framework.
    NSString *groupName = [groupNode nodeName];

    if ([groupsByName objectForKey:groupName])
    {
        DIGSLogWarning(@"Trying to add globals group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupNode];
        [groupsByName setObject:groupNode forKey:[groupNode nodeName]];
    }

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:frameworkName];
}

- (AKGroupNode *)globalsGroupContainingGlobalNamed:(NSString *)nameOfGlobal
                                  inFrameworkNamed:(NSString *)frameworkName
{
    // Get the globals groups for the given framework.
    NSMutableArray *groupList = [_globalsGroupListsByFramework objectForKey:frameworkName];
    if (groupList == nil)
    {
        return nil;
    }

    // Check each globals group to see if it contains the given global.
    for (AKGroupNode *groupNode in groupList)
    {
        if ([groupNode subnodeWithName:nameOfGlobal] != nil)
        {
            return groupNode;
        }
    }

    // If we got this far, we couldn't find the global.
    return nil;
}


#pragma mark -
#pragma mark Getters and setters -- hyperlink support

- (NSString *)frameworkForHTMLFile:(NSString *)htmlFilePath
{
    return [_frameworkNamesByHTMLPath objectForKey:htmlFilePath];
}

- (void)rememberFrameworkName:(NSString *)frameworkName
                  forHTMLFile:(NSString *)htmlFilePath
{
    [_frameworkNamesByHTMLPath setObject:frameworkName forKey:htmlFilePath];
}

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return [_classNodesByHTMLPath objectForKey:htmlFilePath];
}

- (void)rememberThatClass:(AKClassNode *)classNode
   isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    [_classNodesByHTMLPath setObject:classNode forKey:htmlFilePath];
}

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return [_protocolNodesByHTMLPath objectForKey:htmlFilePath];
}

- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode
      isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    [_protocolNodesByHTMLPath setObject:protocolNode forKey:htmlFilePath];
}

- (AKFileSection *)rootSectionForHTMLFile:(NSString *)filePath
{
    return [_rootSectionsByHTMLPath objectForKey:filePath];
}

- (void)rememberRootSection:(AKFileSection *)rootSection
                forHTMLFile:(NSString *)filePath
{
    [_rootSectionsByHTMLPath setObject:rootSection forKey:filePath];
}

- (NSInteger)offsetOfAnchorString:(NSString *)anchorString
                       inHTMLFile:(NSString *)filePath
{
    NSMutableDictionary *offsetsByFilePath = [_offsetsOfAnchorStringsInHTMLFiles objectForKey:anchorString];

    if (offsetsByFilePath == nil)
    {
        return -1;
    }

    NSNumber *offsetValue = [offsetsByFilePath objectForKey:filePath];

    if (offsetValue == nil)
    {
        return -1;
    }

    return [offsetValue intValue];
}

- (void)rememberOffset:(NSInteger)anchorOffset
        ofAnchorString:(NSString *)anchorString
            inHTMLFile:(NSString *)filePath
{
    NSMutableDictionary *offsetsByFilePath = [_offsetsOfAnchorStringsInHTMLFiles objectForKey:anchorString];

    if (offsetsByFilePath == nil)
    {
        offsetsByFilePath = [NSMutableDictionary dictionary];

        [_offsetsOfAnchorStringsInHTMLFiles setObject:offsetsByFilePath forKey:anchorString];
    }

    NSNumber *offsetValue = [NSNumber numberWithInteger:anchorOffset];

    [offsetsByFilePath setObject:offsetValue forKey:filePath];
}

#pragma mark Private methods

- (void)_loadTokensForFrameworkNamed:(NSString *)frameworkName
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

    for (NSString *headerDir in headerDirs)
    {
        [AKObjCHeaderParser recursivelyParseDirectory:headerDir forFramework:aFramework];
    }

    // Parse HTML files.
    NSString *baseDirForDocs = [_docSetIndex baseDirForDocs];

    DIGSLogDebug(@"---------------------------------------------------");
    DIGSLogDebug(@"Parsing HTML docs for framework %@, in base dir %@", frameworkName, baseDirForDocs);
    DIGSLogDebug(@"---------------------------------------------------");

    DIGSLogDebug(@"Parsing behavior docs for framework %@", frameworkName);
    [AKCocoaBehaviorDocParser parseFilesInPaths:[_docSetIndex behaviorDocPathsForFramework:frameworkName]
                                   underBaseDir:baseDirForDocs
                                   forFramework:aFramework];

    DIGSLogDebug(@"Parsing functions docs for framework %@", frameworkName);
    [AKCocoaFunctionsDocParser parseFilesInPaths:[_docSetIndex functionsDocPathsForFramework:frameworkName]
                                    underBaseDir:baseDirForDocs
                                    forFramework:aFramework];

    DIGSLogDebug(@"Parsing globals docs for framework %@", frameworkName);
    [AKCocoaGlobalsDocParser parseFilesInPaths:[_docSetIndex globalsDocPathsForFramework:frameworkName]
                                  underBaseDir:baseDirForDocs
                                  forFramework:aFramework];
}

+ (AKDocSetIndex *)_docSetIndexForDevTools:(AKDevTools *)devTools
                              errorStrings:(NSMutableArray *)errorStrings
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *devToolsPath = [devTools devToolsPath];
    
    if (!([fm fileExistsAtPath:devToolsPath isDirectory:&isDir] && isDir))
    {
        NSString *msg = [NSString stringWithFormat:@"There is no directory at %@.", devToolsPath];
        [errorStrings addObject:msg];
        return nil;
    }

    if ([[devTools sdkVersionsThatAreCoveredByDocSets] count] == 0)
    {
        NSString *msg = [NSString stringWithFormat:@"No docsets were found for any SDKs installed in %@.",
                         devToolsPath];
        [errorStrings addObject:msg];
        return nil;
    }
    
    NSString *sdkVersion = [AKPrefUtils sdkVersionPref];  // If nil, the latest SDK available will be used.
    NSString *docSetSDKVersion = [devTools docSetSDKVersionThatCoversSDKVersion:sdkVersion];
    NSString *docSetPath = [devTools docSetPathForSDKVersion:docSetSDKVersion];

    if (docSetPath == nil)
    {
        NSString *msg = [NSString stringWithFormat:@"No docset was found for the %@ SDK.", sdkVersion];
        [errorStrings addObject:msg];
        return nil;
    }

    NSString *basePathForHeaders = [devTools sdkPathForSDKVersion:sdkVersion];

    if (basePathForHeaders == nil)
    {
        NSString *msg = [NSString stringWithFormat:@"No %@ SDK was found in %@.",
                         sdkVersion, devToolsPath];
        [errorStrings addObject:msg];
        return nil;
    }

    DIGSLogDebug(@"%@ -- docSetPath is [%@]", NSStringFromSelector(_cmd), docSetPath);

    return [[AKDocSetIndex alloc] initWithDocSetPath:docSetPath
                                  basePathForHeaders:basePathForHeaders];
}

// Adds a framework if we haven't seen it before.  We call this each time
// we actually add a bit of API to the database, so that only frameworks
// that we find tokens in are in our list of framework names.
- (void)_seeIfFrameworkIsNew:(NSString *)fwName
{
    if (![_frameworkNames containsObject:fwName])
    {
        [_frameworkNames addObject:fwName];
    }
}

- (NSArray *)_allProtocolsForFrameworkNamed:(NSString *)fwName
{
    return [_protocolListsByFramework objectForKey:fwName];
}

@end


