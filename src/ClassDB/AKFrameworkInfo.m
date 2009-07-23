/*
 * AKFrameworkInfo.h
 *
 * Created by Andy Lee on Sun Jul 04 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFrameworkInfo.h"

#import "DIGSLog.h"
#import "AKPrefUtils.h"
#import "AKDatabase.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKFrameworkInfo (Private)

- (NSString *)_findExistingDirInArray:(NSArray *)dirNames;
- (void)_extractFrameworkInfo:(NSDictionary *)fwInfo;

@end


@implementation AKFrameworkInfo


#pragma mark -
#pragma mark Factory methods

+ (AKFrameworkInfo *)sharedInstance
{
    AKFrameworkInfo *s_sharedInstance = nil;

    if (s_sharedInstance == nil)
    {
        s_sharedInstance = [[AKFrameworkInfo alloc] init];
    }

    return s_sharedInstance;
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        _allPossibleFrameworkNames = [[NSMutableArray array] retain];
        _frameworkClassNamesByFrameworkName = [[NSMutableDictionary dictionary] retain];
        _frameworkPathsByFrameworkName = [[NSMutableDictionary dictionary] retain];
        _docDirsByFrameworkName = [[NSMutableDictionary dictionary] retain];

        // Load FrameworkInfo.plist into a dictionary.
        NSString *frameworkInfoFile =
            [[NSBundle mainBundle] pathForResource:@"FrameworkInfo" ofType:@"plist"];
        NSDictionary *plistContents =
            [NSDictionary dictionaryWithContentsOfFile:frameworkInfoFile];
        if (plistContents == nil)
        {
            DIGSLogError(@"missing or malformed plist: %@", frameworkInfoFile);
            [self release];
            return nil;
        }

        // Iterate through the framework info dictionaries, one for each framework.
        //
        // PLIST["Frameworks"] is an array of:
        //   dictionary with associations:
        //     "FrameworkName" -> (string) framework name
        //     "FrameworkPath" -> (string) /path/to/XXX.framework
        //     "FrameworkClass" -> (string) optional name of framework class
        //     "PossibleDocDirs" -> (array) doc dir names
        //
        // If FrameworkClass is present, it must be the name of a descendant class
        // of AKCocoaFramework (inclusive).  Otherwise, AKCocoaFramework is used.
        NSArray *allFrameworkInfo = [plistContents objectForKey:@"FrameworksOldStyle"];
        if (allFrameworkInfo == nil)
        {
            DIGSLogError(@"FrameworkInfo.plist dictionary is missing \"Frameworks\" key");
            [self release];
            return nil;
        }

        NSEnumerator *fwEnum = [allFrameworkInfo objectEnumerator];
        NSDictionary *fwInfo;
        while ((fwInfo = [fwEnum nextObject]))
        {
            if (![fwInfo isKindOfClass:[NSDictionary class]])
            {
                DIGSLogWarning(@"fwInfo is not a dictionary: %@", fwInfo);
            }
            else
            {
                [self _extractFrameworkInfo:fwInfo];
            }
        }
    }

    return self;
}

- (void)dealloc
{
    [_allPossibleFrameworkNames release];
    [_frameworkClassNamesByFrameworkName release];
    [_frameworkPathsByFrameworkName release];
    [_docDirsByFrameworkName release];

    [super dealloc];
}


#pragma mark -
#pragma mark Getters and setters

- (NSArray *)allPossibleFrameworkNames
{
    return _allPossibleFrameworkNames;
}

- (NSString *)frameworkClassNameForFrameworkNamed:(NSString *)fwName
{
    return [_frameworkClassNamesByFrameworkName objectForKey:fwName];
}

- (NSString *)headerDirForFrameworkNamed:(NSString *)fwName
{
    NSString *frameworkPath = [_frameworkPathsByFrameworkName objectForKey:fwName];

    if (frameworkPath == nil)
        return nil;
    else
        return [frameworkPath stringByAppendingPathComponent:@"Headers"];
}

- (NSString *)docDirForFrameworkNamed:(NSString *)fwName
{
    return [_docDirsByFrameworkName objectForKey:fwName];
}

- (BOOL)frameworkDirsExist:(NSString *)fwName
{
    NSString *headerDir = [self headerDirForFrameworkNamed:fwName];
    NSString *docDir = [self docDirForFrameworkNamed:fwName];

    return ((headerDir != nil) && (docDir != nil));
}

@end



#pragma mark -
#pragma mark Private methods

@implementation AKFrameworkInfo (Private)

- (NSString *)_findExistingDirInArray:(NSArray *)dirNames
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSEnumerator *dirNameEnum = [dirNames objectEnumerator];
    NSString *dirName;

    while ((dirName = [dirNameEnum nextObject]))
    {
        // Tweak the path, replacing /Developer with the Dev Tools location specified in prefs.
        if ([dirName hasPrefix:@"/Developer/"])
        {
            dirName =
                [[AKPrefUtils devToolsPathPref]
                    stringByAppendingPathComponent:
                        [dirName substringFromIndex:[@"/Developer/" length]]];
        }

        // See if a directory exists there.
        BOOL isDir;
        if ([fm fileExistsAtPath:dirName isDirectory:&isDir] && isDir)
        {
            return dirName;
        }
    }

    // If we got this far, the search failed.
    return nil;
}

- (void)_extractFrameworkInfo:(NSDictionary *)fwInfo
{
    NSString *fwName = [fwInfo objectForKey:@"FrameworkName"];
    NSString *frameworkPath = [fwInfo objectForKey:@"FrameworkPath"];
    NSString *fwClassName = [fwInfo objectForKey:@"FrameworkClass"];
    NSArray *possibleDocDirs = [fwInfo objectForKey:@"PossibleDocDirs"];

    // Make sure the dictionary contains all required entries, and they
    // they have the correct data types.  Note that FrameworkClass is
    // not a required entry -- it will default to AKCocoaFramework.
    if (![fwName isKindOfClass:[NSString class]])
    {
        DIGSLogWarning(@"FrameworkName is not a string: [%@]", fwName);
        return;
    }

    if (![frameworkPath isKindOfClass:[NSString class]])
    {
        DIGSLogWarning(
            @"FrameworkPath for framework %@ is not a string: [%@]",
            fwName,
            frameworkPath);
        return;
    }

    if (fwClassName && ![fwClassName isKindOfClass:[NSString class]])
    {
        DIGSLogWarning(
            @"FrameworkClass for framework %@ is not a string: [%@]",
            fwName,
            fwClassName);
        return;
    }

    if (![possibleDocDirs isKindOfClass:[NSArray class]])
    {
        DIGSLogWarning(
            @"PossibleDocDirs for framework %@ is not an array: [%@]",
            fwName,
            possibleDocDirs);
        return;
    }

    // Remember the framework name.
    [_allPossibleFrameworkNames addObject:fwName];

    // Remember the framework location.
    [_frameworkPathsByFrameworkName setObject:frameworkPath forKey:fwName];

    // Can we find a doc dir for this framework?
    NSString *docDir = [self _findExistingDirInArray:possibleDocDirs];

    if (docDir == nil)
    {
        DIGSLogDebug(@"couldn't find a doc dir for %@", fwName);
    }
    else
    {
        [_docDirsByFrameworkName setObject:docDir forKey:fwName];
    }
}

@end
