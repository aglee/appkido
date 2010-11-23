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
- (void)_initDocSetPathsBySDKVersion;

- (NSString *)_docSetVersionForSDKVersion:(NSString *)sdkVersion;
- (void)_initHeadersPathsBySDKVersion;

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

        [self _initDocSetPathsBySDKVersion];
        [self _initHeadersPathsBySDKVersion];
        [_sdkVersionsThatHaveDocSets sortUsingFunction:_versionSortFunction context:NULL];
//        NSLog(@"_sdkVersionsThatHaveDocSets = %@", _sdkVersionsThatHaveDocSets);
//        NSLog(@"_docSetPathsBySDKVersion = %@", _docSetPathsBySDKVersion);
//        NSLog(@"_sdkPathsBySDKVersion = %@", _sdkPathsBySDKVersion);
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

// Called by -initWithPath: to populate _docSetPathsBySDKVersion and _sdkVersionsWithDocSets.  Does this by
// calling _lookForDocSetsInDirectory:.  Must be called before _initHeadersPathsBySDKVersion,
// because the latter depends on _sdkVersionsWithDocSets having been populated.
//
// There are two places to look for docsets: within the Dev Tools directory, and in /Library/Developer.
- (void)_initDocSetPathsBySDKVersion
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

// Called by -initWithPath: to populate _sdkPathsBySDKVersion by locating all
// SDK directories whose versions have corresponding docs, as indicated by _sdkVersionsWithDocSets.
- (void)_initHeadersPathsBySDKVersion
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

@end
