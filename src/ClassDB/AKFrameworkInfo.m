/*
 * AKFrameworkInfo.h
 *
 * Created by Andy Lee on Sun Jul 04 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFrameworkInfo.h"

#import <DIGSLog.h>
#import "AKDatabase.h"
#import "AKCocoaFramework.h"

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKFrameworkInfo (Private)

+ (void)_loadFrameworkInfoPlist;
+ (NSString *)_findExistingDirInArray:(NSArray *)dirNames;
+ (void)_checkNodeClass:(NSString *)fwClassName for:(NSString *)fwName;
+ (void)_extractFrameworkInfo:(NSDictionary *)fwInfo;

@end


@implementation AKFrameworkInfo

//-------------------------------------------------------------------------
// Static variables
//-------------------------------------------------------------------------

// The following have their values assigned by +initFrameworkInfo.  If
// there is a docset index, only s_allPossibleFrameworkNames is actually
// used, and the others remain nil.
static NSMutableArray *s_allPossibleFrameworkNames = nil;
static NSMutableDictionary *s_frameworkClassNamesByFrameworkName = nil;
static NSMutableDictionary *s_frameworkPathsByFrameworkName = nil;
static NSMutableDictionary *s_docDirsByFrameworkName = nil;

//-------------------------------------------------------------------------
// Initialization
//-------------------------------------------------------------------------

/*!
 * Loads the FrameworkInfo.plist, which contains info about frameworks
 * whose documentation we support.
 */
+ (void)initFrameworkInfo
{
    s_allPossibleFrameworkNames = [[NSMutableArray array] retain];
    s_frameworkClassNamesByFrameworkName = [[NSMutableDictionary dictionary] retain];
    s_frameworkPathsByFrameworkName = [[NSMutableDictionary dictionary] retain];
    s_docDirsByFrameworkName = [[NSMutableDictionary dictionary] retain];

    // Load FrameworkInfo.plist into a dictionary.
    NSString *frameworkInfoFile =
        [[NSBundle mainBundle] pathForResource:@"FrameworkInfo" ofType:@"plist"];
    NSDictionary *plistContents =
        [NSDictionary dictionaryWithContentsOfFile:frameworkInfoFile];
    if (plistContents == nil)
    {
        DIGSLogError(@"missing or malformed plist: %@", frameworkInfoFile);
        return;
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
        return;
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

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

+ (NSArray *)allPossibleFrameworkNames
{
    return s_allPossibleFrameworkNames;
}

+ (NSString *)frameworkClassForFrameworkNamed:(NSString *)fwName
{
    return [s_frameworkClassNamesByFrameworkName objectForKey:fwName];
}

+ (NSString *)headerDirForFrameworkNamed:(NSString *)fwName
{
    NSString *frameworkPath = [s_frameworkPathsByFrameworkName objectForKey:fwName];

    if (frameworkPath == nil)
        return nil;
    else
        return [frameworkPath stringByAppendingPathComponent:@"Headers"];
}

+ (NSString *)docDirForFrameworkNamed:(NSString *)fwName
{
    return [s_docDirsByFrameworkName objectForKey:fwName];
}

+ (BOOL)frameworkDirsExist:(NSString *)fwName
{
    NSString *headerDir = [self headerDirForFrameworkNamed:fwName];
    NSString *docDir = [self docDirForFrameworkNamed:fwName];

    return ((headerDir != nil) && (docDir != nil));
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKFrameworkInfo (Private)

+ (void)_loadFrameworkInfoPlist
{
    s_allPossibleFrameworkNames = [[NSMutableArray array] retain];
    s_frameworkClassNamesByFrameworkName = [[NSMutableDictionary dictionary] retain];
    s_frameworkPathsByFrameworkName = [[NSMutableDictionary dictionary] retain];
    s_docDirsByFrameworkName = [[NSMutableDictionary dictionary] retain];

    // Load FrameworkInfo.plist into a dictionary.
    NSString *frameworkInfoFile =
        [[NSBundle mainBundle] pathForResource:@"FrameworkInfo" ofType:@"plist"];
    NSDictionary *plistContents =
        [NSDictionary dictionaryWithContentsOfFile:frameworkInfoFile];
    if (plistContents == nil)
    {
        DIGSLogError(@"missing or malformed plist: %@", frameworkInfoFile);
        return;
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
        return;
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

+ (NSString *)_findExistingDirInArray:(NSArray *)dirNames
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSEnumerator *dirNameEnum = [dirNames objectEnumerator];
    NSString *dirName;

    while ((dirName = [dirNameEnum nextObject]))
    {
        BOOL isDir;

        if ([fm fileExistsAtPath:dirName isDirectory:&isDir] && isDir)
        {
            return dirName;
        }
    }

    // If we got this far, the search failed.
    return nil;
}

+ (void)_checkNodeClass:(NSString *)fwClassName for:(NSString *)fwName
{
	// If we weren't given a framework class name, use AKCocoaFramework.
    if (fwClassName == nil)
    {
        fwClassName = [AKCocoaFramework className];
   }

    Class frameworkClass = NSClassFromString(fwClassName);
    if (frameworkClass == nil)
    {
        DIGSLogDebug(@"[%@] is not the name of a class", fwClassName);
    }
    else
    {
        Class cl = frameworkClass;

        while (cl)
        {
            if (cl == [AKCocoaFramework class])
            {
                break;
            }
            else
            {
                cl = [cl superclass];
            }
        }

        if (cl == nil)
        {
            DIGSLogWarning(
                @"%@ is not a descendant class of AKCocoaFramework",
                fwClassName);
        }
        else
        {
            [s_frameworkClassNamesByFrameworkName
                setObject:fwClassName
                forKey:fwName];
        }
    }
}

+ (void)_extractFrameworkInfo:(NSDictionary *)fwInfo
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
    [s_allPossibleFrameworkNames addObject:fwName];

    // Remember the framework location.
    [s_frameworkPathsByFrameworkName setObject:frameworkPath forKey:fwName];

    // Was a valid class name given?
    [self _checkNodeClass:fwClassName for:fwName];

    // Can we find a doc dir for this framework?
    NSString *docDir = [self _findExistingDirInArray:possibleDocDirs];

    if (docDir == nil)
    {
        DIGSLogDebug(@"couldn't find a doc dir for %@", fwName);
    }
    else
    {
        [s_docDirsByFrameworkName setObject:docDir forKey:fwName];
    }
}

@end
