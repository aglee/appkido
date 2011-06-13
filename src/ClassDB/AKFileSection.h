/*
 * AKFileSection.h
 *
 * Created by Andy Lee on Mon Jul 08 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKFileSection;

/*!
 * @class       AKFileSection
 * @abstract    A named range of bytes within a file.
 * @discussion  An AKFileSection, or "file section," is used to assign a
 *              name to a range of bytes within a file.  A file section can
 *              be associated with other file sections called child
 *              sections.
 *
 *              In AppKiDo, file sections are used to partition an HTML
 *              file into a hierarchy of smaller chunks of documentation.
 *              For example, an HTML file that documents a class is
 *              partitioned into sections for class methods, instance
 *              methods, delegate methods, etc.
 */
@interface AKFileSection : NSObject
{
@private
    NSString *_filePath;
    NSData *_fileContents;

    NSString *_sectionName;

    NSUInteger _sectionOffset;
    NSUInteger _sectionLength;

    // Elements are AKFileSections.
    NSMutableArray *_childSections;
}


#pragma mark -
#pragma mark Factory methods

/*!
 * @method      withFile:
 * @discussion  Returns a new instance whose range is (0, 0).
 */
+ (AKFileSection *)withFile:(NSString *)filePath;

/*!
 * @method      withEntireFile:
 * @discussion  Returns a new instance whose range is the entire text file.
 */
+ (AKFileSection *)withEntireFile:(NSString *)filePath;


#pragma mark -
#pragma mark Init/awake/dealloc

/*!
 * @method      initWithFile:
 * @discussion  Designated initializer.
 */
- (id)initWithFile:(NSString *)filePath;


#pragma mark -
#pragma mark Getters and setters

/*!
 * @method      filePath
 * @discussion  Returns the path of my file.  Subclasses must override.
 */
- (NSString *)filePath;

/*!
 * @method      fileContents
 * @discussion  Returns the contents of my file.  Subclasses must override.
 */
- (NSData *)fileContents;

- (NSString *)sectionName;
- (void)setSectionName:(NSString *)name;

- (NSUInteger)sectionOffset;
- (void)setSectionOffset:(NSUInteger)offset;

- (NSUInteger)sectionLength;
- (void)setSectionLength:(NSUInteger)length;

- (NSData *)sectionData;

- (NSEnumerator *)childSectionEnumerator;
- (NSInteger)numberOfChildSections;
- (AKFileSection *)childSectionAtIndex:(NSInteger)index;
- (AKFileSection *)childSectionWithName:(NSString *)name;
- (AKFileSection *)lastChildSection;
- (NSInteger)indexOfChildSectionWithName:(NSString *)name;
- (BOOL)hasChildSectionWithName:(NSString *)name;
- (void)addChildSection:(AKFileSection *)childSection;
- (void)insertChildSection:(AKFileSection *)childSection
    atIndex:(NSInteger)index;
- (void)removeChildSectionAtIndex:(NSInteger)index;
- (AKFileSection *)childSectionContainingString:(NSString *)name; // thanks Gerriet



#pragma mark -
#pragma mark AKSortable methods

/*!
 * @method      sortName
 * @discussion  Returns the section name.
 */
- (NSString *)sortName;

@end
