//
//  AKDevTools.m
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AKDevTools.h"

#import "DIGSLog.h"
#import "AKFileUtils.h"
#import "AKTextUtils.h"
#import "AKDocSetIndex.h"
#import "AKSDKVersion.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKDevTools ()

- (void)_lookForDocSetsInDirectory:(NSString *)docSetsDir;
- (void)_findAllDocSetPaths;
- (void)_findAllSDKPathsWithDocSets;
- (void)_removeDocSetPathsWithoutSDKs;

@end


#pragma mark -

@implementation AKDevTools

// Used for sorting the version strings in _sdkVersionsWithDocSets.
static int _versionSortFunction(id leftVersionString, id rightVersionString, void *ignoredContext)
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
    return [[[self alloc] initWithPath:devToolsPath] autorelease];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithPath:(NSString *)devToolsPath
{
    if ((self = [super init]))
    {
        _devToolsPath = [devToolsPath retain];
        _docSetPathsBySDKVersion = [[NSMutableDictionary alloc] init];
        _sdkVersionsThatHaveDocSets = [[NSMutableArray alloc] init];
        _sdkPathsBySDKVersion = [[NSMutableDictionary alloc] init];

        [self _findAllDocSetPaths];
        [self _findAllSDKPathsWithDocSets];
        [self _removeDocSetPathsWithoutSDKs];
        [_sdkVersionsThatHaveDocSets sortUsingFunction:_versionSortFunction context:NULL];
    }

    return self;
}

- (void)dealloc
{
    [_devToolsPath release];
    [_docSetPathsBySDKVersion release];
    [_sdkVersionsThatHaveDocSets release];
    [_sdkPathsBySDKVersion release];

    [super dealloc];
}


#pragma mark -
#pragma mark Dev Tools paths

+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath errorStrings:(NSMutableArray *)errorStrings
{
    if (devToolsPath == nil)
    {
        [errorStrings addObject:@"The given path is nil."];
        return NO;
    }
    
    if (![AKFileUtils directoryExistsAtPath:devToolsPath])
    {
        [errorStrings addObject:@"Directory doesn't exist."];
        return NO;
    }
    
    NSEnumerator *expectedSubdirsEnum = [[NSArray arrayWithObjects:
#if APPKIDO_FOR_IPHONE
                                          @"Platforms/iPhoneOS.platform",
                                          @"Platforms/iPhoneSimulator.platform",
#endif
                                          @"Applications/Xcode.app",
                                          @"Documentation",
                                          @"Examples",
                                          nil] objectEnumerator];
    NSString *subdir;
    BOOL seemsOkay = YES;
    
    while ((subdir = [expectedSubdirsEnum nextObject]))
    {
        NSString *expectedSubdirPath = [devToolsPath stringByAppendingPathComponent:subdir];
        if (![AKFileUtils directoryExistsAtPath:expectedSubdirPath])
        {
            NSString *error = [NSString stringWithFormat:@"Missing subdirectory \"%@\".", subdir];
            [errorStrings addObject:error];
            seemsOkay = NO;
        }
    }
    
    return seemsOkay;
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

- (NSString *)docSetPathForSDKVersion:(NSString *)sdkVersion
{
    if (sdkVersion == nil)
    {
        sdkVersion = [_sdkVersionsThatHaveDocSets lastObject];
    }
    
    return [_docSetPathsBySDKVersion objectForKey:sdkVersion];
}


#pragma mark -
#pragma mark SDK paths

- (NSString *)sdkSearchPath
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSArray *)sdkVersionsThatHaveDocSets
{
    return _sdkVersionsThatHaveDocSets;
}

- (NSString *)sdkPathForSDKVersion:(NSString *)sdkVersion
{
    if (sdkVersion == nil)
    {
        sdkVersion = [_sdkVersionsThatHaveDocSets lastObject];
    }
    
    return [_sdkPathsBySDKVersion objectForKey:sdkVersion];
}


#pragma mark -
#pragma mark Private methods

// Adds entries to _docSetPathsBySDKVersion and _sdkVersionsWithDocSets by locating all docsets in the given directory.
- (void)_lookForDocSetsInDirectory:(NSString *)docSetsDir
{
    NSEnumerator *dirContentsEnum = [[[NSFileManager defaultManager] directoryContentsAtPath:docSetsDir] objectEnumerator];
    NSString *fileName;

    while ((fileName = [dirContentsEnum nextObject]))
    {
        if ([self isValidDocSetName:fileName])
        {
            NSString *docSetPath = [docSetsDir stringByAppendingPathComponent:fileName];
            NSString *plistPath = [docSetPath stringByAppendingPathComponent:@"Contents/Info.plist"];
            NSDictionary *docSetPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];

            if (docSetPlist == nil)
            {
                DIGSLogInfo(@"couldn't read plist at location %@", plistPath);
            }
            else
            {
                NSString *sdkVersion = [docSetPlist objectForKey:@"DocSetPlatformVersion"];

                if (![_sdkVersionsThatHaveDocSets containsObject:sdkVersion])
                {
                    [_sdkVersionsThatHaveDocSets addObject:sdkVersion];
                }

                [_docSetPathsBySDKVersion setObject:docSetPath forKey:sdkVersion];
            }
        }
    }
}

- (void)_findAllDocSetPaths
{
    NSEnumerator *docSetPathEnum = [[self docSetSearchPaths] objectEnumerator];
    NSString *docSetPath;
    
    while ((docSetPath = [docSetPathEnum nextObject]))
    {
        [self _lookForDocSetsInDirectory:docSetPath];
    }
}

- (NSString *)_docSetVersionForSDKVersion:(NSString *)sdkVersion
{
	NSEnumerator *docSetVersionsEnum = [_sdkVersionsThatHaveDocSets objectEnumerator];
	NSString *docSetVersion;
	
	while ((docSetVersion = [docSetVersionsEnum nextObject]))
	{
		if ([[AKSDKVersion versionFromString:docSetVersion] coversVersion:[AKSDKVersion versionFromString:sdkVersion]])
		{
			return docSetVersion;
		}
	}
	
	// If we got this far, we did not find a match.
	return nil;
}

// Finds all SDK directories within our Dev Tools directory for which we have found corresponding
// docsets.  Must be called after _findAllDocSetPaths so we know what docsets are available.
- (void)_findAllSDKPathsWithDocSets
{
    NSString *sdksDir = [self sdkSearchPath];
    NSEnumerator *dirContentsEnum = [[[NSFileManager defaultManager] directoryContentsAtPath:sdksDir] objectEnumerator];
    NSString *fileName;

    while ((fileName = [dirContentsEnum nextObject]))
    {
        if ([[fileName pathExtension] isEqualToString:@"sdk"])
        {
            NSString *sdkPath = [sdksDir stringByAppendingPathComponent:fileName];
            NSString *plistPath = [sdkPath stringByAppendingPathComponent:@"SDKSettings.plist"];
            NSDictionary *sdkPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            NSString *sdkVersion = [sdkPlist objectForKey:@"Version"];
			NSString *docSetVersion = [self _docSetVersionForSDKVersion:sdkVersion];

            if (docSetVersion != nil)
            {
                [_sdkPathsBySDKVersion setObject:sdkPath forKey:docSetVersion];
            }
        }
    }
}

- (void)_removeDocSetPathsWithoutSDKs
{
    NSEnumerator *sdkVersionsEnum = [[NSArray arrayWithArray:_sdkVersionsThatHaveDocSets] objectEnumerator];
    NSString *sdkVersion;
    
    while ((sdkVersion = [sdkVersionsEnum nextObject]))
    {
        if ([_sdkPathsBySDKVersion objectForKey:sdkVersion] == nil)
        {
            [_sdkVersionsThatHaveDocSets removeObject:sdkVersion];
            [_docSetPathsBySDKVersion removeObjectForKey:sdkVersion];
        }
    }
}

@end
