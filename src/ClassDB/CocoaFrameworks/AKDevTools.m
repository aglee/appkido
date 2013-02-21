//
//  AKDevTools.m
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 Andy Lee. All rights reserved.
//

#import "AKDevTools.h"

#import "AKFileUtils.h"
#import "AKIPhoneDevTools.h"
#import "AKMacDevTools.h"
#import "AKSDKVersion.h"

#import "DIGSLog.h"

@implementation AKDevTools
{
@private
    NSString *_devToolsPath;

    // Paths to all docsets we find, both within this Dev Tools installation and
    // in the various shared locations where docsets are installed.
    NSMutableDictionary *_installedDocSetPathsBySDKVersion;

    // Paths to all SDKs we find within this Dev Tools installation.
    NSMutableDictionary *_installedSDKPathsBySDKVersion;
}


// Used for sorting SDK version strings. [agl] Why didn't I use AKSDKVersion to do the comparing?
static NSComparisonResult _versionSortFunction(id leftVersionString, id rightVersionString, void *ignoredContext)
{
    NSArray *leftComponents = [(NSString *)leftVersionString componentsSeparatedByString:@"."];
    NSArray *rightComponents = [(NSString *)rightVersionString componentsSeparatedByString:@"."];
    unsigned int i;

    for (i = 0; i < [leftComponents count]; i++)
    {
        if (i >= [rightComponents count])
            return NSOrderedDescending;  // left has more components and is therefore greater than right

        int leftNumber = [[leftComponents objectAtIndex:i] intValue];
        int rightNumber = [[rightComponents objectAtIndex:i] intValue];

        if (leftNumber < rightNumber)
            return NSOrderedAscending;
        else if (leftNumber > rightNumber)
            return NSOrderedDescending;
    }

    // If we got this far, rightComponents has leftComponents as a prefix.
    if ([leftComponents count] < [rightComponents count])
        return NSOrderedAscending;  // left has fewer components and is therefore less than right
    else
        return NSOrderedSame;  // all left components equal all right components
}


#pragma mark -
#pragma mark Factory methods

+ (id)devToolsWithPath:(NSString *)devToolsPath
{
    return [[self alloc] initWithPath:devToolsPath];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithPath:(NSString *)devToolsPath
{
    if ((self = [super init]))
    {
        _devToolsPath = devToolsPath;
        _installedDocSetPathsBySDKVersion = [[NSMutableDictionary alloc] init];
        _installedSDKPathsBySDKVersion = [[NSMutableDictionary alloc] init];

        [self _findInstalledDocSetPaths];
        [self _findInstalledSDKPaths];
    }

    return self;
}


#pragma mark -
#pragma mark Dev Tools paths

+ (BOOL)devToolsPathIsOldStyle:(NSString *)devToolsPath
{
    for (NSString *pathComponent in [devToolsPath pathComponents])
    {
        if ([[pathComponent pathExtension] isEqualToString:@"app"])
        {
            return NO;
        }
    }

    return YES;
}

+ (NSArray *)expectedSubdirsForDevToolsPath:(NSString *)devToolsPath
{
#if APPKIDO_FOR_IPHONE
    return [AKIPhoneDevTools expectedSubdirsForDevToolsPath:devToolsPath];
#else
    return [AKMacDevTools expectedSubdirsForDevToolsPath:devToolsPath];
#endif
}

+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath
                      errorStrings:(NSMutableArray *)errorStrings
{
    if (devToolsPath == nil)
    {
        [errorStrings addObject:@"The Dev Tools path is unspecified."];
        return NO;
    }
    
    if (![AKFileUtils directoryExistsAtPath:devToolsPath])
    {
        NSString *errorString = [NSString stringWithFormat:@"The directory \"%@\" doesn't exist.", devToolsPath];
        [errorStrings addObject:errorString];
        return NO;
    }
    
    NSArray *expectedSubdirs = [self expectedSubdirsForDevToolsPath:devToolsPath];
    NSEnumerator *expectedSubdirsEnum = [expectedSubdirs objectEnumerator];
    NSString *subdir;
    
    while ((subdir = [expectedSubdirsEnum nextObject]))
    {
        NSString *expectedSubdirPath = [devToolsPath stringByAppendingPathComponent:subdir];
        if (![AKFileUtils directoryExistsAtPath:expectedSubdirPath])
        {
            NSString *errorString = [NSString stringWithFormat:@"The directory \"%@\" doesn't exist.",
                                     expectedSubdirPath];
            [errorStrings addObject:errorString];
            return NO;
        }
    }

    // If we got this far, the path seems okay.
    return YES;
}

- (NSString *)devToolsPath
{
    return _devToolsPath;
}


#pragma mark -
#pragma mark Docset paths

- (NSArray *)docSetSearchPaths
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (BOOL)isValidDocSetName:(NSString *)fileName
{
    DIGSLogError_MissingOverride();
    return NO;
}

- (NSString *)docSetPathForSDKVersion:(NSString *)docSetSDKVersion
{
    return [_installedDocSetPathsBySDKVersion objectForKey:docSetSDKVersion];

    // The following was useful for testing how we handle the case when a docset
    // needs to be downloaded.
    //return @"/Users/alee/Xcode2.app/Contents/Developer/Documentation/DocSets/com.apple.adc.documentation.AppleOSX10_8.CoreReference.docset";
}


#pragma mark -
#pragma mark SDK paths

- (NSString *)sdkSearchPath
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSArray *)sdkVersionsThatAreCoveredByDocSets
{
    NSMutableArray *sdkVersions = [NSMutableArray array];

    for (NSString *installedSDKVersion in _installedSDKPathsBySDKVersion)
    {
        if ([self docSetSDKVersionThatCoversSDKVersion:installedSDKVersion])
        {
            [sdkVersions addObject:installedSDKVersion];
        }
    }

    [sdkVersions sortUsingFunction:_versionSortFunction context:NULL];
    return sdkVersions;
}

- (NSString *)sdkPathForSDKVersion:(NSString *)sdkVersion
{
    if (sdkVersion == nil)
    {
        sdkVersion = [[self sdkVersionsThatAreCoveredByDocSets] lastObject];
    }
    
    return [_installedSDKPathsBySDKVersion objectForKey:sdkVersion];
}


#pragma mark -
#pragma mark SDK versions

- (NSString *)docSetSDKVersionThatCoversSDKVersion:(NSString *)sdkVersion
{
	for (NSString *docSetVersion in _installedDocSetPathsBySDKVersion)
	{
		if ([[AKSDKVersion versionFromString:docSetVersion] coversVersion:[AKSDKVersion versionFromString:sdkVersion]])
		{
			return docSetVersion;
		}
	}

	// If we got this far, we did not find a match.
	return nil;
}


#pragma mark -
#pragma mark Private methods -- called during init

// Locates all docsets in the given directory. Adds entries to _installedDocSetPathsBySDKVersion.
- (void)_findDocSetsInDirectory:(NSString *)docSetSearchPath
{
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docSetSearchPath error:NULL];

    for (NSString *fileName in dirContents)
    {
        if ([self isValidDocSetName:fileName])
        {
            NSString *docSetPath = [docSetSearchPath stringByAppendingPathComponent:fileName];
            NSString *plistPath = [docSetPath stringByAppendingPathComponent:@"Contents/Info.plist"];
            NSDictionary *docSetPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];

            if (docSetPlist == nil)
            {
                DIGSLogInfo(@"ODD -- couldn't load docset's plist at %@.", plistPath);
            }
            else
            {
                NSString *sdkVersion = [docSetPlist objectForKey:@"DocSetPlatformVersion"];

                if (sdkVersion == nil)
                {
                    DIGSLogInfo(@"ODD -- docset's plist at %@ contains no 'DocSetPlatformVersion' key.",
                                plistPath);
                }
                else
                {
                    [_installedDocSetPathsBySDKVersion setObject:docSetPath forKey:sdkVersion];
                }
            }
        }
    }
}

- (void)_findInstalledDocSetPaths
{
    for (NSString *docSetSearchPath in [self docSetSearchPaths])
    {
        [self _findDocSetsInDirectory:docSetSearchPath];
    }
}

// Locates all docsets in the given directory. Adds entries to _installedSDKPathsBySDKVersion.
- (void)_findSDKsInDirectory:(NSString *)sdkSearchPath
{
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sdkSearchPath error:NULL];

    for (NSString *dirItem in dirContents)
    {
        if ([[dirItem pathExtension] isEqualToString:@"sdk"])
        {
            NSString *sdkPath = [sdkSearchPath stringByAppendingPathComponent:dirItem];
            NSString *plistPath = [sdkPath stringByAppendingPathComponent:@"SDKSettings.plist"];
            NSDictionary *sdkPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];

            if (sdkPlist == nil)
            {
                DIGSLogInfo(@"ODD -- couldn't load SDK's plist at %@.", plistPath);
            }
            else
            {
                NSString *sdkVersion = [sdkPlist objectForKey:@"Version"];

                if (sdkVersion == nil)
                {
                    DIGSLogInfo(@"ODD -- SDK's plist at %@ contains no 'Version' key.", plistPath);
                }
                else
                {
                    [_installedSDKPathsBySDKVersion setObject:sdkPath forKey:sdkVersion];
                }
            }
        }
    }
}

- (void)_findInstalledSDKPaths
{
    [self _findSDKsInDirectory:[self sdkSearchPath]];
}

@end
