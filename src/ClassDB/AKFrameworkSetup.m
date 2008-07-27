//
//  AKFrameworkSetup.m
//  AppKiDo
//
//  Created by Andy Lee on 4/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKFrameworkSetup.h"

#import "DIGSLog.h"

#import "AKFileUtils.h"
#import "AKPrefUtils.h"
#import "AKDocSetBasedFramework.h"
#import "AKDocSetIndex.h"

#import "AKCocoaFramework.h"
#import "AKFrameworkInfo.h"



//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKFrameworkSetup (Private)
- (BOOL)_directory:(NSString *)dir hasSubdirectory:(NSString *)subdir;
- (BOOL)_looksLikeValidDevToolsPath:(NSString *)devToolsPath;
- (void)_getFrameworkInfoFromPlist;
- (void)_getFrameworkInfoFromDocSetIndex:(AKDocSetIndex *)docSetIndex;
@end



@implementation AKFrameworkSetup

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)frameworkSetupBasedOnPrefs
{
    return [[[self alloc] init] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)init
{
    if ((self = [super init]))
    {
        // Make sure we have a valid dev tools path.
        NSString *devToolsPath = [AKPrefUtils devToolsPathPref];

        if (![self _looksLikeValidDevToolsPath:devToolsPath])
        {
            [self release];
            return nil;
        }

        // Populate the available-frameworks ivars.  Use the docset
        // approach if CoreReference.docset exists in the Dev Tools
        // directory.  Otherwise, use the old pre-docset approach using
        // FrameworkInfo.plist.
        _availableFrameworks = [[NSMutableArray alloc] init];
        _namesOfAvailableFrameworks = [[NSMutableArray alloc] init];
        _availableFrameworksByName = [[NSMutableDictionary alloc] init];

        AKDocSetIndex *docSetIndex = nil;
        NSString *docSetPath = nil;
        NSString *basePathForHeaders = nil;

BOOL isForIPhone = NO;  // [agl] REMOVE
if (isForIPhone)
{
        docSetPath =
            [devToolsPath
                stringByAppendingPathComponent:
                    @"Platforms/iPhoneOS.platform/"
                    "Developer/Documentation/DocSets/"
                    "com.apple.adc.documentation.AppleiPhone2_0.iPhoneLibrary.docset"];
        basePathForHeaders =
            [devToolsPath
                stringByAppendingPathComponent:
                    @"Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator2.0.sdk"];
}
else
{
        docSetPath =
            [devToolsPath
                stringByAppendingPathComponent:
                    @"Documentation/DocSets/"
                    "com.apple.ADC_Reference_Library.CoreReference.docset"];
        basePathForHeaders = @"/";
}

        docSetIndex =
            [[[AKDocSetIndex alloc]
                initWithDocSetPath:docSetPath
                basePathForHeaders:basePathForHeaders] autorelease];

        if (docSetIndex)
        {
            // Load frameworks from the docset.
            DIGSLogDebug(@"found docset at %@", docSetPath);
            [self _getFrameworkInfoFromDocSetIndex:docSetIndex];
        }
        else
        {
            // Use FrameworkInfo.plist to load frameworks.
            DIGSLogDebug(@"did not find docset at %@ -- will use old approach", docSetPath);
            [self _getFrameworkInfoFromPlist];
        }
    }

    return self;
}

- (void)dealloc
{
    [_availableFrameworks release];
    [_namesOfAvailableFrameworks release];
    [_availableFrameworksByName release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSArray *)availableFrameworks
{
    return _availableFrameworks;
}

- (NSArray *)namesOfAvailableFrameworks
{
    return _namesOfAvailableFrameworks;
}

- (AKFramework *)frameworkNamed:(NSString *)fwName
{
    return [_availableFrameworksByName objectForKey:fwName];
}

@end


@implementation AKFrameworkSetup (Private)

- (BOOL)_directory:(NSString *)dir hasSubdirectory:(NSString *)subdir
{
    BOOL subdirExists =
        [AKFileUtils
            directoryExistsAtPath:
                [dir stringByAppendingPathComponent:subdir]];

    if (!subdirExists)
    {
        DIGSLogDebug(
            @"%@ doesn't seem to be a valid Dev Tools path"
                " -- it doesn't have a subdirectory %@",
            dir, subdir);
    }

    return subdirExists;
}

- (BOOL)_looksLikeValidDevToolsPath:(NSString *)devToolsPath
{
    return
        [self _directory:devToolsPath hasSubdirectory:@"Applications"]
        && [self _directory:devToolsPath hasSubdirectory:@"Examples"];
}

// Called on init in the case where there is no Leopard-style docset database.
// Gets list of frameworks from FrameworkInfo.plist.
// Creates instances of AKCocoaFramework.
- (void)_getFrameworkInfoFromPlist
{
    NSArray *namesOfPossibleFrameworks =
        [AKFrameworkInfo allPossibleFrameworkNames];

    NSEnumerator *fwNameEnum = [namesOfPossibleFrameworks objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNameEnum nextObject]))
    {
        if ([AKFrameworkInfo frameworkDirsExist:fwName])
        {
            AKFramework *fw =
                [[[AKCocoaFramework alloc] initWithName:fwName] autorelease];

            if (fw)
            {
                [_availableFrameworks addObject:fw];
                [_namesOfAvailableFrameworks addObject:fwName];
                [_availableFrameworksByName setObject:fw forKey:fwName];
            }
        }
    }
}

// Called on init in the case where there is a Leopard-style docset database.
// Gets list of frameworks from the specified docset.
// Creates instances of AKDocSetBasedFramework.
- (void)_getFrameworkInfoFromDocSetIndex:(AKDocSetIndex *)docSetIndex
{
    if (docSetIndex == nil)
    {
        return;
    }

    NSArray *namesOfPossibleFrameworks = [docSetIndex objectiveCFrameworkNames];
    NSEnumerator *fwNameEnum = [namesOfPossibleFrameworks objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNameEnum nextObject]))
    {
        AKDocSetBasedFramework *fw =
            [_availableFrameworksByName objectForKey:fwName];

        if (fw != nil)
        {
            DIGSLogWarning(@"trying to add framework %@ twice", fwName);
        }
        else
        {
            fw =
                [[[AKDocSetBasedFramework alloc]
                    initWithName:fwName
                    docSetIndex:docSetIndex] autorelease];

            [_availableFrameworks addObject:fw];
            [_namesOfAvailableFrameworks addObject:fwName];
            [_availableFrameworksByName setObject:fw forKey:fwName];
        }
    }
}

@end
