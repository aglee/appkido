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


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKDevTools ()
- (void)_initDocSetPathsByVersion;
- (void)_initHeadersPathsByVersion;
@end


#pragma mark -

@implementation AKDevTools

// Used for sorting the version strings in _sdkVersions.
static int _versionSortFunction(id leftVersionString, id rightVersionString, void *ignoredContext)
{
    NSArray *leftComponents = [(NSString *)leftVersionString componentsSeparatedByString:@"."];
    NSArray *rightComponents = [(NSString *)rightVersionString componentsSeparatedByString:@"."];
    unsigned int i;

    for (i = 0; i < [leftComponents count]; i++)
    {
        if (i >= [rightComponents count])
            return NSOrderedDescending;  // leftVersionString is greater than rightVersionString

        int leftNumber = [[leftComponents objectAtIndex:i] intValue];
        int rightNumber = [[rightComponents objectAtIndex:i] intValue];

        if (leftNumber < rightNumber)
            return NSOrderedAscending;
        else if (leftNumber > rightNumber)
            return NSOrderedDescending;
    }

    // If we got this far, rightComponents has leftComponents as a prefix.
    if ([leftComponents count] < [rightComponents count])
        return NSOrderedAscending;  // leftVersionString is less than rightVersionString
    else
        return NSOrderedSame;  // leftVersionString equals rightVersionString
}


#pragma mark -
#pragma mark Factory methods

+ (id)devToolsWithPath:(NSString *)devToolsPath
{
    return [[[self alloc] initWithPath:devToolsPath] autorelease];
}


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithPath:(NSString *)devToolsPath
{
    if ((self = [super init]))
    {
        _devToolsPath = [devToolsPath retain];
        _sdkVersions = [[NSMutableArray alloc] init];
        _docSetPathsByVersion = [[NSMutableDictionary alloc] init];
        _headersPathsByVersion = [[NSMutableDictionary alloc] init];

        [self _initDocSetPathsByVersion];
        [self _initHeadersPathsByVersion];
        [_sdkVersions sortUsingFunction:_versionSortFunction context:NULL];
//        NSLog(@"_sdkVersions = %@", _sdkVersions);
//        NSLog(@"_docSetPathsByVersion = %@", _docSetPathsByVersion);
//        NSLog(@"_headersPathsByVersion = %@", _headersPathsByVersion);
    }

    return self;
}

- (void)dealloc
{
    [_devToolsPath release];
    [_sdkVersions release];
    [_docSetPathsByVersion release];
    [_headersPathsByVersion release];

    [super dealloc];
}


#pragma mark -
#pragma mark Getters and setters

- (NSString *)devToolsPath
{
    return _devToolsPath;
}

- (NSArray *)sdkVersions
{
    return _sdkVersions;
}

- (NSString *)docSetPathForVersion:(NSString *)sdkVersion
{
    if (sdkVersion == nil)
        sdkVersion = [_sdkVersions lastObject];
    return [_docSetPathsByVersion objectForKey:sdkVersion];
}

- (NSString *)headersPathForVersion:(NSString *)sdkVersion
{
    if (sdkVersion == nil)
        sdkVersion = [_sdkVersions lastObject];
    return [_headersPathsByVersion objectForKey:sdkVersion];
}


#pragma mark -
#pragma mark Validation

+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath
{
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

    while ((subdir = [expectedSubdirsEnum nextObject]))
    {
        NSString *expectedSubdirPath = [devToolsPath stringByAppendingPathComponent:subdir];
        if (![AKFileUtils directoryExistsAtPath:expectedSubdirPath])
        {
            DIGSLogDebug(@"%@ doesn't seem to be a valid Dev Tools path -- it doesn't have a subdirectory %@",
                devToolsPath, subdir);
            return NO;
        }
    }

    // If we got this far, we're going to assume the path is a valid Dev Tools path.
    return YES;
}


#pragma mark -
#pragma mark Private methods

// Called by -initWithPath: to populate _docSetPathsByVersion by locating all available
// docsets.  Adds to _sdkVersions as it goes.  Must be called before _initHeadersPathsByVersion,
// because the latter depends on _sdkVersions having been populated.
- (void)_initDocSetPathsByVersion
{
    NSString *docSetsDir = [_devToolsPath stringByAppendingPathComponent:[self relativePathToDocSetsDir]];
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

                if (![_sdkVersions containsObject:sdkVersion])
                    [_sdkVersions addObject:sdkVersion];

                [_docSetPathsByVersion setObject:docSetPath forKey:sdkVersion];
            }
        }
    }
}

// Called by -initWithPath: to populate _headersPathsByVersion by locating all
// SDK directories whose versions have corresponding docs, as indicated by _sdkVersions.
- (void)_initHeadersPathsByVersion
{
    NSString *sdksDir = [_devToolsPath stringByAppendingPathComponent:[self relativePathToHeadersDir]];
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

            if ([_sdkVersions containsObject:sdkVersion])
                [_headersPathsByVersion setObject:sdkPath forKey:sdkVersion];
        }
    }

    // Prune SDK versions for which we found docs but no headers.
    NSEnumerator *versionEnum = [[_sdkVersions copy] objectEnumerator];
    NSString *sdkVersion;

    while ((sdkVersion = [versionEnum nextObject]))
    {
        if ([_headersPathsByVersion objectForKey:sdkVersion] == nil)
        {
            DIGSLogInfo(@"found docs but not headers for version [%@]", sdkVersion);
            [_sdkVersions removeObject:sdkVersion];
            [_docSetPathsByVersion removeObjectForKey:sdkVersion];
        }
    }
}


#pragma mark -
#pragma mark For internal use only

- (NSString *)relativePathToDocSetsDir
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSString *)relativePathToHeadersDir
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (BOOL)isValidDocSetName:(NSString *)fileName
{
    DIGSLogError_MissingOverride();
    return NO;
}

@end
