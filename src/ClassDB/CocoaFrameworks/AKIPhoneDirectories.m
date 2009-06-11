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

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKIPhoneDirectories ()
- (NSString *)_latestIPhonePathInDirectory:(NSString *)dirPath;
@end


@implementation AKIPhoneDirectories

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)iPhoneDirectoriesWithDevToolsPath:(NSString *)devToolsPath
{
    return [[[self alloc] initWithDevToolsPath:devToolsPath] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithDevToolsPath:(NSString *)devToolsPath
{
    if ((self = [super init]))
    {
        _devToolsPath = [devToolsPath retain];
    }

    return self;
}

- (void)dealloc
{
    [_devToolsPath release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)docSetsDir
{
    return
        [_devToolsPath
            stringByAppendingPathComponent:
                @"Platforms/iPhoneOS.platform/Developer/Documentation/DocSets/"];
}

- (NSString *)sdksDir
{
    return
        [_devToolsPath
            stringByAppendingPathComponent:
                @"Platforms/iPhoneOS.platform/Developer/SDKs/"];
}

- (NSString *)pathToLatestDocSet
{
    return [self _latestIPhonePathInDirectory:[self docSetsDir]];
}

- (NSString *)pathToLatestHeadersDir
{
    return [self _latestIPhonePathInDirectory:[self sdksDir]];
}

//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

- (NSString *)_latestIPhonePathInDirectory:(NSString *)dirPath
{
    NSEnumerator *dirContentsEnum =
        [[[NSFileManager defaultManager]
            directoryContentsAtPath:dirPath]
            objectEnumerator];
    NSString *fileName;
    NSDate *latestDate = nil;
    NSString *latestFile = nil;

    while ((fileName = [dirContentsEnum nextObject]))
    {
        if ([fileName ak_containsCaseInsensitive:@"iPhone"])
        {
            NSDictionary *fileAttributes =
                [[NSFileManager defaultManager]
                    fileAttributesAtPath:
                        [dirPath stringByAppendingPathComponent:fileName]
                    traverseLink:YES];
            NSDate *modDate = [fileAttributes fileModificationDate];

            if (latestDate == nil ||
                [modDate compare:latestDate] == NSOrderedDescending)
            {
                latestDate = modDate;
                latestFile = fileName;
            }

            DIGSLogDebug(@"_latestIPhonePathInDirectory: -- [%@] -- [%@]",
                modDate, fileName);
        }
    }

    DIGSLogDebug(@"[%@] ** [%@]", latestDate, latestFile);
    return [dirPath stringByAppendingPathComponent:latestFile];
}

@end
