//
//  AKFileSectionCache.h
//  AppKiDo
//
//  Created by Andy Lee on 2/25/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Internal use by AKFileSection. Assumes files read-only. Not thread-safe.
 * Terms "like"/"unlike" (borrowed from the social media world) analogous to
 * retain/release for deciding when to purge resources.
 *
 * Moved this over from AKFileSection, where I thought I saw a bunch of
 * gibberish code before I understood my intent. //TODO: look at NSCache
 */
@interface AKFileSectionCache : NSObject
{
@private
    // Keys are file paths, values are NSData instances containing file
    // contents. We assume files are read-only so we don't have to worry about
    // a stale cache.
    NSMutableDictionary *_fileCache;

    // Keys are file paths, values are NSValues whose intValues are the number
    // of times the file is referenced by an AKFileSection. "Cache count" is
    // analogous to retain count in memory management terms.
    NSMutableDictionary *_fileCacheCounts;
}

#pragma mark - Accessing the cache

/*!
 * Likes the file and returns its contents. Calls to this must be balanced
 * by calls to unlikeFileAtPath:.
 */
- (NSData *)likeFileAtPath:(NSString *)filePath;  //TODO: Use NSError**?

/*!
 * Decrements the file's "like" count. When the count goes to 0 the file is
 * evicted from the cache.
 */
- (void)unlikeFileAtPath:(NSString *)filePath;

@end
