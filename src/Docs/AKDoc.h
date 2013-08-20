/*
 * AKDoc.h
 *
 * Created by Andy Lee on Mon Mar 15 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKFileSection;

/*!
 * Abstract class that encapsulates one of the docs that fall under an
 * AKSubtopic. An AKDoc is essentially a wrapper around a piece of text that
 * comes from an AKFileSection. Depending on the type of doc, the doc text might
 * be either plain text or HTML.
 *
 * UI notes: when a doc is selected in the doc list, the selected AKDoc provides
 * the text to display in the doc view, and also the string to display in the
 * comment field at the bottom of the window.
 */
@interface AKDoc : NSObject

#pragma mark -
#pragma mark Getters and setters

/*!
 * Subclasses must override. Returns a file section containing the text
 * associated with this doc. When the doc text is HTML, the filePath of this
 * file section is used as the base URL for links in the HTML.
 */
- (AKFileSection *)fileSection;

/*! Returns YES if the doc text contains HTML. Defaults to YES. */
- (BOOL)docTextIsHTML;

/*!
 * Returns YES if [self docTextData] should include text from the descendant
 * sections of [self fileSection]. Defaults to YES.
 */
- (BOOL)docTextShouldIncludeDescendantSections;

/*! The doc text. */
- (NSData *)docTextData;

/*!
 * Returns the doc name that should be used in doc locators. This name must be
 * unique among all the docs in a given subtopic's doc list.
 *
 * By default, returns [[self fileSection] sectionName] with HTML markup
 * stripped.
 */
- (NSString *)docName;

/*!
 * Returns the string that should be displayed in the doc list table. Defaults
 * to [self docName].
 */
- (NSString *)stringToDisplayInDocList;

/*!
 * Returns the string to display in the comment field at the bottom of the
 * window. Default is the empty string.
 */
- (NSString *)commentString;

@end
