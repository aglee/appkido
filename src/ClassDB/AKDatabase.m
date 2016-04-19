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

#pragma mark -
#pragma mark Factory methods

+ (instancetype)databaseWithErrorStrings:(NSMutableArray *)errorStrings
{
    // Instantiate AKDevTools.
    NSString *devToolsPath = [AKPrefUtils devToolsPathPref];

    if (![AKDevTools looksLikeValidDevToolsPath:devToolsPath errorStrings:errorStrings])
    {
        return nil;
    }

#if APPKIDO_FOR_IPHONE
    AKDevTools *devTools = [AKIPhoneDevTools devToolsWithPath:devToolsPath];
#else
    AKDevTools *devTools = [AKMacDevTools devToolsWithPath:devToolsPath];
#endif

    // Use that to instantiate AKDocSetIndex.
    AKDocSetIndex *docSetIndex = [self _docSetIndexForDevTools:devTools
                                                  errorStrings:errorStrings];
    if (docSetIndex == nil)
    {
        return nil;
    }

    // Use that to instantiate AKDatabase.
    AKDatabase *dbToReturn = [[self alloc] initWithDocSetIndex:docSetIndex];

    // Query the sqlite database for the location of the NSObject class doc, and see if that
    // file exists.  If not, the reason is probably that the user has to download the docs.
    //
    // [agl] How does Xcode know whether to put an "Install" button by the docset?  I would
    // guess it checks the RSS feed -- at least there *used* to be a feed for docs.  I believe
    // docsets have version numbers, so maybe Xcode compares the number from the feed to the
    // currently installed number.
    NSString *docsBaseDirPath = [docSetIndex baseDirForDocs];
    NSString *relativeDocPathForNSObject = [docSetIndex relativePathToDocsForClassNamed:@"NSObject"];
    NSString *docPathForNSObject = [docsBaseDirPath stringByAppendingPathComponent:relativeDocPathForNSObject];

    if (![[NSFileManager defaultManager] fileExistsAtPath:docPathForNSObject])
    {
        NSString *msg = [NSString stringWithFormat:(@"The selected docset (%@) is missing documentation for NSObject."
                                                    @" Usually this means you need to download the docset."
                                                    @" You can do this by going to Xcode > Preferences > Downloads > Documentation."
//                                                    @"\n\nAlternatively, you can try selecting a different SDK."
                                                    ),
                                                    [docSetIndex docSetPath]];
        [errorStrings addObject:msg];
        return nil;
    }

    // If we got this far, we can return a valid AKDatabase instance.  Before we do, check
    // whether any selected frameworks have been specified; if not, select a default set.
    if ([AKPrefUtils selectedFrameworkNamesPref] == nil)
    {
#if APPKIDO_FOR_IPHONE
        // Assume a new user of AppKiDo-for-iPhone is going to want all possible
        // frameworks in the iPhone SDK by default, and will deselect whichever
        // ones they don't want.  The docset is small enough that we can do this.  [agl] Still?
        NSArray *namesOfDefaultFrameworksToSelect = [docSetIndex selectableFrameworkNames];
#else
        // For a new user of AppKiDo for Mac OS, only load the "essential"
        // frameworks by default and leave it up to them to add more as needed.
        // It would be nice to simply provide everything, but until we cut down
        // the amount of startup time used by parsing, that will take too long.
        NSArray *namesOfDefaultFrameworksToSelect = AKNamesOfEssentialFrameworks;
#endif

        [AKPrefUtils setSelectedFrameworkNamesPref:namesOfDefaultFrameworksToSelect];
    }

    return dbToReturn;
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(AKDocSetIndex *)docSetIndex
{
    if ((self = [super init]))
    {
        _docSetIndex = docSetIndex;

        _frameworkNames = [[NSMutableArray alloc] init];
        _namesOfAvailableFrameworks = [[docSetIndex selectableFrameworkNames] copy];

        _classNodesByName = [[NSMutableDictionary alloc] init];

        _protocolNodesByName = [[NSMutableDictionary alloc] init];

        _functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _classNodesByHTMLPath = [[NSMutableDictionary alloc] init];
        _protocolNodesByHTMLPath = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark Populating the database

- (void)loadTokensForFrameworkWithName:(NSString *)fwName
{
    if ([[_docSetIndex selectableFrameworkNames] containsObject:fwName])
    {
        @autoreleasepool
        {
            DIGSLogDebug(@"===================================================");
            DIGSLogDebug(@"Loading tokens for framework %@", fwName);
            DIGSLogDebug(@"===================================================");

            [self _loadTokensForFrameworkNamed:fwName];
        }
    }
}

#pragma mark -
#pragma mark Getters and setters -- frameworks

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
    NSMutableArray *classNodes = [NSMutableArray array];

    for (AKClassNode *classNode in [self allClasses])
    {
        if ([classNode.nameOfOwningFramework isEqualToString:frameworkName])
        {
            [classNodes addObject:classNode];
        }
    }

    return classNodes;
}

- (NSArray *)rootClasses
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKClassNode *classNode in [self allClasses])
    {
        if (classNode.parentClass == nil)
        {
            [result addObject:classNode];
        }
    }

    return result;
}

- (NSArray *)allClasses
{
    return _classNodesByName.allValues;
}

- (AKClassNode *)classWithName:(NSString *)className
{
    return _classNodesByName[className];
}

- (void)addClassNode:(AKClassNode *)classNode
{
    // Do nothing if we already have a class with the same name.
    NSString *className = classNode.nodeName;
    if (_classNodesByName[className])
    {
        DIGSLogDebug3(@"Trying to add class [%@] again", className);
        return;
    }

    // Add the class to our lookup by class name.
    _classNodesByName[className] = classNode;

    // Add the class's framework to our framework list if it's not there already.
    if (classNode.nameOfOwningFramework)
    {
        [self _seeIfFrameworkIsNew:classNode.nameOfOwningFramework];
    }
}

#pragma mark -
#pragma mark Getters and setters -- protocols

- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
    return [self _allProtocolsForFrameworkNamed:frameworkName withInformalFlag:NO];
}

- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
    return [self _allProtocolsForFrameworkNamed:frameworkName withInformalFlag:YES];
}

- (NSArray *)allProtocols
{
    return _protocolNodesByName.allValues;
}

- (AKProtocolNode *)protocolWithName:(NSString *)name
{
    return _protocolNodesByName[name];
}

- (void)addProtocolNode:(AKProtocolNode *)protocolNode
{
    // Do nothing if we already have a protocol with the same name.
    NSString *protocolName = protocolNode.nodeName;
    if (_protocolNodesByName[protocolName])
    {
        DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
        return;
    }

    // Add the protocol to our lookup by protocol name.
    _protocolNodesByName[protocolName] = protocolNode;

    // Add the class's framework to our framework list if it's not there already.
    if (protocolNode.nameOfOwningFramework)
    {
        [self _seeIfFrameworkIsNew:protocolNode.nameOfOwningFramework];
    }
}

#pragma mark -
#pragma mark Getters and setters -- functions

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return _functionsGroupListsByFramework[frameworkName];
}

- (AKGroupNode *)functionsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName
{
    return _functionsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addFunctionsGroup:(AKGroupNode *)groupNode
{
    NSString *frameworkName = groupNode.nameOfOwningFramework;

    // See if we have any functions groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName = _functionsGroupsByFrameworkAndGroup[frameworkName];

    if (groupsByName)
    {
        groupList = _functionsGroupListsByFramework[frameworkName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        _functionsGroupsByFrameworkAndGroup[frameworkName] = groupsByName;

        groupList = [NSMutableArray array];
        _functionsGroupListsByFramework[frameworkName] = groupList;
    }

    // Add the functions group if it isn't already in the framework.
    NSString *groupName = groupNode.nodeName;

    if (groupsByName[groupName])
    {
        DIGSLogWarning(@"Trying to add functions group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupNode];
        groupsByName[groupNode.nodeName] = groupNode;
    }

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:frameworkName];
}

#pragma mark -
#pragma mark Getters and setters -- globals

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return _globalsGroupListsByFramework[frameworkName];
}

- (AKGroupNode *)globalsGroupNamed:(NSString *)groupName
                  inFrameworkNamed:(NSString *)frameworkName
{
    return _globalsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addGlobalsGroup:(AKGroupNode *)groupNode
{
    NSString *frameworkName = groupNode.nameOfOwningFramework;

    // See if we have any globals groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName = _globalsGroupsByFrameworkAndGroup[frameworkName];

    if (groupsByName)
    {
        groupList = _globalsGroupListsByFramework[frameworkName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        _globalsGroupsByFrameworkAndGroup[frameworkName] = groupsByName;

        groupList = [NSMutableArray array];
        _globalsGroupListsByFramework[frameworkName] = groupList;
    }

    // Add the globals group if it isn't already in the framework.
    NSString *groupName = groupNode.nodeName;

    if (groupsByName[groupName])
    {
        DIGSLogWarning(@"Trying to add globals group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupNode];
        groupsByName[groupNode.nodeName] = groupNode;
    }

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:frameworkName];
}

#pragma mark -
#pragma mark Methods that help AKCocoaGlobalsDocParser

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return _classNodesByHTMLPath[htmlFilePath];
}

- (void)rememberThatClass:(AKClassNode *)classNode
   isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    _classNodesByHTMLPath[htmlFilePath] = classNode;
}

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return _protocolNodesByHTMLPath[htmlFilePath];
}

- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode
      isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    _protocolNodesByHTMLPath[htmlFilePath] = protocolNode;
}

#pragma mark -
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
    NSSet *headerDirs = [_docSetIndex headerDirsForFramework:frameworkName];

    for (NSString *headerDir in headerDirs)
    {
        [AKObjCHeaderParser recursivelyParseDirectory:headerDir
                                          forDatabase:self
                                        frameworkName:frameworkName];
    }

    // Parse HTML files.
    NSString *baseDirForDocs = [_docSetIndex baseDirForDocs];

    DIGSLogDebug(@"---------------------------------------------------");
    DIGSLogDebug(@"Parsing HTML docs for framework %@, in base dir %@", frameworkName, baseDirForDocs);
    DIGSLogDebug(@"---------------------------------------------------");

    DIGSLogDebug(@"Parsing behavior docs for framework %@", frameworkName);
    [AKCocoaBehaviorDocParser parseFilesInSubpaths:[_docSetIndex behaviorDocPathsForFramework:frameworkName]
                                      underBaseDir:baseDirForDocs
                                       forDatabase:self
                                     frameworkName:frameworkName];

    DIGSLogDebug(@"Parsing functions docs for framework %@", frameworkName);
    [AKCocoaFunctionsDocParser parseFilesInSubpaths:[_docSetIndex functionsDocPathsForFramework:frameworkName]
                                       underBaseDir:baseDirForDocs
                                        forDatabase:self
                                      frameworkName:frameworkName];

    DIGSLogDebug(@"Parsing globals docs for framework %@", frameworkName);
    [AKCocoaGlobalsDocParser parseFilesInSubpaths:[_docSetIndex globalsDocPathsForFramework:frameworkName]
                                     underBaseDir:baseDirForDocs
                                      forDatabase:self
                                    frameworkName:frameworkName];
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

    if ([devTools sdkVersionsThatAreCoveredByDocSets].count == 0)
    {
        NSString *msg = [NSString stringWithFormat:@"No docsets were found for any SDKs installed in %@.",
                         devToolsPath];
        [errorStrings addObject:msg];
        return nil;
    }
    
    NSString *sdkVersion = [AKPrefUtils sdkVersionPref];  // If nil, the latest SDK available will be used.

    if (sdkVersion == nil)
    {
        sdkVersion = [devTools sdkVersionsThatAreCoveredByDocSets].lastObject;
    }

    if (sdkVersion == nil)
    {
        NSString *msg = [NSString stringWithFormat:@"No docset was found for any installed SDK."];
        [errorStrings addObject:msg];
        return nil;
    }

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
// [agl] Linear search has been okay so far.
- (void)_seeIfFrameworkIsNew:(NSString *)fwName
{
    if (![_frameworkNames containsObject:fwName])
    {
        [_frameworkNames addObject:fwName];
    }
}

- (NSArray *)_allProtocolsForFrameworkNamed:(NSString *)fwName
                           withInformalFlag:(BOOL)informalFlag
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKProtocolNode *protocolNode in [self allProtocols])
    {
        if ((protocolNode.isInformal == informalFlag)
            && [protocolNode.nameOfOwningFramework isEqualToString:fwName])
        {
            [result addObject:protocolNode];
        }
    }

    return result;
}

@end
