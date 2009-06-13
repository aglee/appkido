//
//  AKIPhoneDirectories.m
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AKIPhoneDirectories.h"

#import "DIGSLog.h"
#import "AKTextUtils.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKIPhoneDirectories ()
- (void)_initDocSetPathsByVersion;
- (void)_initHeadersPathsByVersion;
@end


#pragma mark -

@implementation AKIPhoneDirectories

#pragma mark -
#pragma mark Function for sorting version strings

static NSInteger _versionSortFunction(id leftVersionString, id rightVersionString, void *ignoredContext)
{
    NSArray *leftComponents = [(NSString *)leftVersionString componentsSeparatedByString:@"."];
    NSArray *rightComponents = [(NSString *)rightVersionString componentsSeparatedByString:@"."];
    NSUInteger i;

    for (i = 0; i < [leftComponents count]; i++)
    {
        if (i >= [rightComponents count])
            return NSOrderedDescending;  // leftVersionString is greater than rightVersionString

        NSInteger leftNumber = [[leftComponents objectAtIndex:i] intValue];
        NSInteger rightNumber = [[rightComponents objectAtIndex:i] intValue];

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

+ (id)iPhoneDirectoriesWithDevToolsPath:(NSString *)devToolsPath
{
    return [[[self alloc] initWithDevToolsPath:devToolsPath] autorelease];
}


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithDevToolsPath:(NSString *)devToolsPath
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
        //NSLog(@"_sdkVersions = %@", _sdkVersions);
        //NSLog(@"_docSetPathsByVersion = %@", _docSetPathsByVersion);
        //NSLog(@"_headersPathsByVersion = %@", _headersPathsByVersion);
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
    return [_docSetPathsByVersion objectForKey:sdkVersion];
}

- (NSString *)headersPathForVersion:(NSString *)sdkVersion
{
    return [_headersPathsByVersion objectForKey:sdkVersion];
}

- (NSString *)docSetPathForLatestVersion
{
    return [_docSetPathsByVersion objectForKey:[_sdkVersions lastObject]];
}

- (NSString *)headersPathForLatestVersion
{
    return [_headersPathsByVersion objectForKey:[_sdkVersions lastObject]];
}


#pragma mark -
#pragma mark Private methods

// Called by -initWithDevToolsPath: to populate _docSetPathsByVersion by locating all available
// docsets.  Adds to _sdkVersions as it goes.  Must be called before _initHeadersPathsByVersion,
// because the latter depends on _sdkVersions having been populated.
- (void)_initDocSetPathsByVersion
{
    NSString *docSetsDir = [_devToolsPath stringByAppendingPathComponent:@"Platforms/iPhoneOS.platform/Developer/Documentation/DocSets/"];
    NSEnumerator *dirContentsEnum = [[[NSFileManager defaultManager] directoryContentsAtPath:docSetsDir] objectEnumerator];
    NSString *fileName;

    while ((fileName = [dirContentsEnum nextObject]))
    {
        if ([[fileName pathExtension] isEqualToString:@"docset"])
        {
            NSString *docSetPath = [docSetsDir stringByAppendingPathComponent:fileName];
            NSString *plistPath = [docSetPath stringByAppendingPathComponent:@"Contents/Info.plist"];
            NSDictionary *docSetPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            NSString *sdkVersion = [docSetPlist objectForKey:@"DocSetPlatformVersion"];

            if (![_sdkVersions containsObject:sdkVersion])
                [_sdkVersions addObject:sdkVersion];

            [_docSetPathsByVersion setObject:docSetPath forKey:sdkVersion];
        }
    }
}

// Called by -initWithDevToolsPath: to populate _headersPathsByVersion by locating all
// SDK directories whose versions have corresponding docs, as indicated by _sdkVersions.
- (void)_initHeadersPathsByVersion
{
    NSString *sdksDir = [_devToolsPath stringByAppendingPathComponent:@"Platforms/iPhoneOS.platform/Developer/SDKs/"];
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

@end
