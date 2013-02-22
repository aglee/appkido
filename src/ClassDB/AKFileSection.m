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


#pragma mark -
#pragma mark Static variables

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



#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKFileSection (Private)
- (void)_releaseFileContents;
@end


@implementation AKFileSection


#pragma mark -
#pragma mark Class initializer

+ (void)initialize
{
    s_fileCache = [[NSMutableDictionary alloc] init];
    s_fileCacheCounts = [[NSMutableDictionary alloc] init];
}


#pragma mark -
#pragma mark Factory methods

+ (AKFileSection *)withFile:(NSString *)filePath
{
    AKFileSection *fileSection =
        [[self alloc] initWithFile:filePath];

    [fileSection setSectionName:[filePath lastPathComponent]];
    [fileSection setSectionOffset:0];
    [fileSection setSectionLength:0];

    return fileSection;
}

+ (AKFileSection *)withEntireFile:(NSString *)filePath
{
    // Find out the file size.
    NSFileWrapper *fileWrapper =
        [[NSFileWrapper alloc] initWithPath:filePath];
    NSDictionary *fileAttributes = [fileWrapper fileAttributes];
    int fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];

    // Create the new instance.
    AKFileSection *fileSection = [self withFile:filePath];

    [fileSection setSectionName:[filePath lastPathComponent]];
    [fileSection setSectionOffset:0];
    [fileSection setSectionLength:fileSize];

    return fileSection;
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithFile:(NSString *)filePath
{
    if ((self = [super init]))
    {
        _filePath = filePath;
        _childSections = [[NSMutableArray alloc] init];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}

- (void)dealloc
{
    // Note that _releaseFileContents references _filePath, so we need to call
    // it *before* releasing _filePath, which might get dealloc'ed.
    [self _releaseFileContents];
}


#pragma mark -
#pragma mark Getters and setters

- (NSString *)filePath
{
    return _filePath;
}

- (NSData *)fileContents
{
    if ((_fileContents == nil) && (_filePath != nil))
    {
        // See if the file is already in the cache.
        _fileContents = [s_fileCache objectForKey:_filePath];

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
    _sectionName = name;
}

- (NSUInteger)sectionOffset
{
    return _sectionOffset;
}

- (void)setSectionOffset:(NSUInteger)offset
{
    _sectionOffset = offset;
}

- (NSUInteger)sectionLength
{
    return _sectionLength;
}

- (void)setSectionLength:(NSUInteger)length
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

- (NSArray *)childSections
{
    return [_childSections copy];
}

- (NSInteger)numberOfChildSections
{
    return [_childSections count];
}

- (AKFileSection *)childSectionAtIndex:(NSInteger)childSectionIndex
{
    return [_childSections objectAtIndex:childSectionIndex];
}

- (AKFileSection *)childSectionWithName:(NSString *)name
{
    for (AKFileSection *childSection in _childSections)
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
    NSInteger numSubs = [_childSections count];

    return
        (numSubs == 0)
        ? nil
        : [_childSections objectAtIndex:(numSubs - 1)];
}

- (NSInteger)indexOfChildSectionWithName:(NSString *)name
{
    NSInteger numChildSections = [_childSections count];
    NSInteger i;

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
    atIndex:(NSInteger)childSectionIndex
{
    [_childSections insertObject:childSection atIndex:childSectionIndex];
}

- (void)removeChildSectionAtIndex:(NSInteger)childSectionIndex
{
    [_childSections removeObjectAtIndex:childSectionIndex];
}

- (AKFileSection *)childSectionContainingString:(NSString *)name  // thanks Gerriet
{
   for (AKFileSection *childSection in _childSections)
   {
		NSData *data = [childSection sectionData];
		NSString *d = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSRange rr = [d rangeOfString:name];
		if (rr.location != NSNotFound)
        {
            return childSection;
        }
   }

   return nil;
}


#pragma mark -
#pragma mark Debugging

- (void)_printTreeWithDepth:(NSUInteger)depth intoString:(NSMutableString *)s
{
    // Print this section's name at the indicated indentation level.
    NSUInteger i;
    for (i = 0; i < depth; i++)
    {
        [s appendString:@"    "];
    }
    
    [s appendString:[self sectionName]];
    [s appendString:[NSString stringWithFormat:@" (%ld-%ld, %ld chars)",
                     (long)[self sectionOffset],
                     (long)[self sectionOffset] + [self sectionLength],
                     (long)[self sectionLength]]];
    [s appendString:@"\n"];
    
    // Print child sections.
    for (AKFileSection *childSection in _childSections)
    {
        [childSection _printTreeWithDepth:(depth + 1) intoString:s];
    }
}

- (NSString *)descriptionAsOutline
{
    NSMutableString *s = [NSMutableString stringWithCapacity:2000];
    
    [self _printTreeWithDepth:0 intoString:s];
    
    return s;
}


#pragma mark -
#pragma mark AKSortable methods

- (NSString *)sortName
{
    return _sectionName;
}


#pragma mark -
#pragma mark NSObject methods

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



#pragma mark -
#pragma mark Private methods

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
    _fileContents = nil;
}

@end


