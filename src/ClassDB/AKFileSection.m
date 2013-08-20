/*
 * AKFileSection.m
 *
 * Created by Andy Lee on Mon Jul 08 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFileSection.h"

#import <AppKit/NSFileWrapper.h>

#import "DIGSLog.h"

#import "AKFileSectionCache.h"

#pragma mark -
#pragma mark Static variables

static AKFileSectionCache *s_fileSectionCache = nil;

@implementation AKFileSection

#pragma mark -
#pragma mark Class initializer

+ (void)initialize
{
    s_fileSectionCache = [[AKFileSectionCache alloc] init];
}

#pragma mark -
#pragma mark Factory methods

+ (AKFileSection *)withFile:(NSString *)filePath
{
    AKFileSection *fileSection = [[[self alloc] initWithFile:filePath] autorelease];

    [fileSection setSectionName:[filePath lastPathComponent]];
    [fileSection setSectionOffset:0];
    [fileSection setSectionLength:0];

    return fileSection;
}

+ (AKFileSection *)withEntireFile:(NSString *)filePath
{
    // Find out the file size.
    NSFileWrapper *fileWrapper = [[[NSFileWrapper alloc] initWithPath:filePath] autorelease];
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
        _filePath = [filePath copy];
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
    [s_fileSectionCache unlikeFileAtPath:_filePath];

    [_filePath release];
    [_fileContents release];
    [_sectionName release];
    [_childSections release];

    [super dealloc];
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
        _fileContents = [[s_fileSectionCache likeFileAtPath:_filePath] retain];
    }

    return _fileContents;
}

- (NSString *)sectionName
{
    return _sectionName;
}

- (void)setSectionName:(NSString *)name
{
    [_sectionName autorelease];
    _sectionName = [name copy];
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
    return [[_childSections copy] autorelease];
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

    return ((numSubs == 0)
            ? nil
            : [_childSections objectAtIndex:(numSubs - 1)]);
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
		NSString *d = [[[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding] autorelease];
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
    return [NSString stringWithFormat:@"<%@: sectionName=%@, filePath=%@>",
            [self className], _sectionName, [self filePath]];
}

@end
