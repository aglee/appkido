/*
 * AKDoc.h
 *
 * Created by Andy Lee on Mon Mar 15 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKFileSection;

/*!
 * @class       AKDoc
 * @abstract    Encapsulates one of the documentation items listed in
 *              the doc list.
 * @discussion  Each row in the doc list is associated with an AKDoc.
 *              (The doc list is the NSTableView on the right side of
 *              the middle section of the window; it is managed by an
 *              AKDocListController.)  An AKDoc is essentially a wrapper
 *              around an AKFileSection, with some extra behavior added.
 *
 *              When a doc is selected in the doc list, the selected
 *              AKDoc provides the text to display in the bottom pane,
 *              and also the comment to display below that along the
 *              bottom of the window.
 *
 *              AKDoc is an abstract class.  Subclasses represent
 *              different kinds of docs that may be listed in the doc
 *              list.
 */
@interface AKDoc : NSObject

#pragma mark -
#pragma mark Getters and setters

/*!
 * @method      fileSection
 * @discussion  Returns a file section containing the text that should be
 *              displayed when the user selects me in the doc list table.
 *              The -filePath of this file section is used as the base
 *              URL for links in the documentation text.
 *
 *              Subclasses must override.
 */
- (AKFileSection *)fileSection;

/*!
 * @method      isPlainText
 * @discussion  Returns YES if my file section contains plain text that
 *              should be displayed in its raw form.  Returns NO (the
 *              default) if my file section contains HTML that should be
 *              converted to an attributed string before being displayed.
 */
- (BOOL)isPlainText;

/*!
 * @method      textIncludesDescendantSections
 * @discussion  If this returns YES, the text I display includes text
 *              from my file section's descendant sections.  Defaults
 *              to YES.
 */
- (BOOL)textIncludesDescendantSections;

- (NSData *)docTextData;

/*!
 * @method      docName
 * @discussion  Returns the name used to refer to the doc in doc locators
 *              and in the prefs file.  This name must be unique among
 *              all the docs in a doc list.
 *
 *              By default, my doc name is the de-HTMLized -sectionName
 *              of my file section.
 *
 *              My doc name is not necessarily what is displayed in the
 *              doc list table.  To get my displayed name, use
 *              -stringToDisplayInDocList.
 */
- (NSString *)docName;

/*!
 * @method      stringToDisplayInDocList
 * @discussion  Returns the string that should be displayed in the
 *              doc list table.  Defaults to my -docName.
 */
- (NSString *)stringToDisplayInDocList;

/*!
 * @method      commentString
 * @discussion  Returns the string that should be displayed in the
 *              comments area at the bottom of the window when I am
 *              selected in the doc list table.  By default, returns the
 *              empty string.
 */
- (NSString *)commentString;

@end
