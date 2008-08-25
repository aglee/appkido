/*
 * AKFileSection.m
 *
 * Created by Andy Lee on Mon Jul 08 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFileSection.h"

#import <AppKit/NSFileWrapper.h>

#import "DIGSLog.h"

#import "AKTextUtils.h"
#import "AKFileSection.h"

//-------------------------------------------------------------------------
// Static variables
//-------------------------------------------------------------------------

// Keys are file paths, values are NSData instances containing file
// contents.
//
// Note: we assume files are read-only so we don't have to worry about
// a stale cache.
static NSMutableDictionary *s_fileCache = nil;

// Keys are file paths, values are NSValues whose intValues are the
// number of times the file is referenced by an AKFileSection's
// _fileContents instance.
static NSMutableDictionary *s_fileCacheCounts = nil;


//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKFileSection (Private)
- (void)_releaseFileContents;
@end


@implementation AKFileSection

//-------------------------------------------------------------------------
// Class initializer
//-------------------------------------------------------------------------

+ (void)initialize
{
    s_fileCache = [[NSMutableDictionary alloc] init];
    s_fileCacheCounts = [[NSMutableDictionary alloc] init];
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKFileSection *)withFile:(NSString *)filePath
{
    AKFileSection *fileSection =
        [[[self alloc] initWithFile:filePath] autorelease];

    [fileSection setSectionName:[filePath lastPathComponent]];
    [fileSection setSectionOffset:0];
    [fileSection setSectionLength:0];

    return fileSection;
}

+ (AKFileSection *)withEntireFile:(NSString *)filePath
{
    // Find out the file size.
    NSFileWrapper *fileWrapper =
        [[[NSFileWrapper alloc] initWithPath:filePath] autorelease];
    NSDictionary *fileAttributes = [fileWrapper fileAttributes];
    int fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];

    // Create the new instance.
    AKFileSection *fileSection = [self withFile:filePath];

    [fileSection setSectionName:[filePath lastPathComponent]];
    [fileSection setSectionOffset:0];
    [fileSection setSectionLength:fileSize];

    return fileSection;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithFile:(NSString *)filePath
{
    if ((self = [super init]))
    {
        _filePath = [filePath retain];
        _childSections = [[NSMutableArray alloc] init];
    }

    return self;
}

- (id)init
{
    DIGSLogNondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    // Note that _releaseFileContents references _filePath, so we need to call
    // it *before* releasing _filePath, which might get dealloc'ed.
    [self _releaseFileContents];

    [_filePath release];
    [_sectionName release];
    [_childSections release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)filePath
{
    return _filePath;
}

- (NSData *)fileContents
{
    if ((_fileContents == nil) && (_filePath != nil))
    {
        // See if the file is already in the cache.
        _fileContents = [[s_fileCache objectForKey:_filePath] retain];

        if (_fileContents != nil)
        {
            // The file is already in the cache, so increment the cache
            // count.
            int cacheCount =
                [[s_fileCacheCounts objectForKey:_filePath] intValue];

            [s_fileCacheCounts
                setObject:[NSNumber numberWithInt:(cacheCount + 1)]
                forKey:_filePath];
        }
        else
        {
            // The file wasn't in the cache, so add it with a cache
            // count of 1.
            _fileContents =
                [[NSData alloc] initWithContentsOfFile:_filePath];
            [s_fileCache setObject:_fileContents forKey:_filePath];
            [s_fileCacheCounts
                setObject:[NSNumber numberWithInt:1]
                forKey:_filePath];
        }
    }

    return _fileContents;
}

- (NSString *)sectionName
{
    return _sectionName;
}

- (void)setSectionName:(NSString *)name
{
    [name retain];
    [_sectionName release];
    _sectionName = name;
}

- (unsigned)sectionOffset
{
    return _sectionOffset;
}

- (void)setSectionOffset:(unsigned)offset
{
    _sectionOffset = offset;
}

- (unsigned)sectionLength
{
    return _sectionLength;
}

- (void)setSectionLength:(unsigned)length
{
    _sectionLength = length;
}

- (NSData *)sectionData
{
    NSData *fileContents = [self fileContents];

    if (fileContents == nil)
    {
        return nil;
    }
    else
    {
        NSRange range = NSMakeRange(_sectionOffset, _sectionLength);

        return [fileContents subdataWithRange:range];
    }
}

- (NSEnumerator *)childSectionEnumerator
{
    return [_childSections objectEnumerator];
}

- (int)numberOfChildSections
{
    return [_childSections count];
}

- (AKFileSection *)childSectionAtIndex:(int)index
{
    return [_childSections objectAtIndex:index];
}

- (AKFileSection *)childSectionWithName:(NSString *)name
{
    NSEnumerator *en = [_childSections objectEnumerator];
    AKFileSection *childSection;

    while ((childSection = [en nextObject]))
    {
        NSString *childSectionName = [childSection sectionName];

        if ([childSectionName caseInsensitiveCompare:name] == NSOrderedSame)
        {
            return childSection;
        }
    }

    return nil;
}

- (AKFileSection *)lastChildSection
{
    int numSubs = [_childSections count];

    return
        (numSubs == 0)
        ? nil
        : [_childSections objectAtIndex:(numSubs - 1)];
}

- (int)indexOfChildSectionWithName:(NSString *)name
{
    int numChildSections = [_childSections count];
    int i;

    for (i = 0; i < numChildSections; i++)
    {
        AKFileSection *childSection = [_childSections objectAtIndex:i];
        NSString *childSectionName = [childSection sectionName];

        if ([childSectionName caseInsensitiveCompare:name] == NSOrderedSame)
        {
            return i;
        }
    }

    // If we got this far, the search failed.
    return -1;
}

- (BOOL)hasChildSectionWithName:(NSString *)name
{
    return ([self indexOfChildSectionWithName:name] >= 0);
}

- (void)addChildSection:(AKFileSection *)childSection
{
    [_childSections addObject:childSection];
}

- (void)insertChildSection:(AKFileSection *)childSection
    atIndex:(int)index
{
    [_childSections insertObject:childSection atIndex:index];
}

- (void)removeChildSectionAtIndex:(int)index
{
    [_childSections removeObjectAtIndex:index];
}

- (AKFileSection *)childSectionContainingString:(NSString *)name  // thanks Gerriet
{
   NSEnumerator *en = [_childSections objectEnumerator];
   AKFileSection *childSection;

   while ((childSection = [en nextObject]))
   {
		NSData *data = [childSection sectionData];
		NSString *d = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSRange rr = [d rangeOfString:name];
		[d release];
		if (rr.location != NSNotFound)
        {
            return childSection;
        }
   }

   return nil;
}

//-------------------------------------------------------------------------
// AKSortable methods
//-------------------------------------------------------------------------

- (NSString *)sortName
{
    return _sectionName;
}

//-------------------------------------------------------------------------
// NSObject methods
//-------------------------------------------------------------------------

- (NSString *)description
{
    return
        [NSString stringWithFormat:
            @"<%@: sectionName=%@, filePath=%@>",
            [self className],
            _sectionName,
            [self filePath]];
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKFileSection (Private)

// Releases the _fileContents ivar and decrements the corresponding cache
// count.
- (void)_releaseFileContents
{
    // Decrement the cache count.
    int cacheCount =
        [[s_fileCacheCounts objectForKey:_filePath] intValue];

    if (cacheCount == 1)
    {
        // This was the last reference -- remove the file from the cache.
        [s_fileCache removeObjectForKey:_filePath];
    }
    else
    {
        // Decrement the cache count.
        [s_fileCacheCounts
            setObject:[NSNumber numberWithInt:(cacheCount - 1)]
            forKey:_filePath];
    }


    // Now we can release the ivar.
    [_fileContents release];
    _fileContents = nil;
}

@end


