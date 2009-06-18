/*
 * AKOverviewDoc.h
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFileSectionDoc.h"

/*!
 * @class       AKOverviewDoc
 */
@interface AKOverviewDoc : AKFileSectionDoc
{
    NSString *_extraFrameworkName;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer -- okay to use super's DI
- (id)initWithFileSection:(AKFileSection *)fileSection
    andExtraFrameworkName:(NSString *)frameworkName;

/*!
 * @method      initWithFileSection:
 * @discussion  Designated initializer for AKDoc.
 * @param       fileSection  Contains the text that should be displayed
 *              when the user selects me in the doc list table.  The
 *              -filePath of this file section is used as the base
 *              URL for links in the documentation text.
 */
- (id)initWithFileSection:(AKFileSection *)fileSection;

//-------------------------------------------------------------------------
// Utility methods
//-------------------------------------------------------------------------

// An overview doc list may contain docs for more than one framework.
// If frameworkName is nil, returns docName unchanged.
+ (NSString *)qualifyDocName:(NSString *)docName withFrameworkName:(NSString *)frameworkName;

//-------------------------------------------------------------------------
// Protected methods
//-------------------------------------------------------------------------

// Used to construct both my doc name and my display string.  My doc name
// and display string "qualify" my unqualified doc name (i.e., add my
// extra framework name) in different ways.
- (NSString *)_unqualifiedDocName;

@end
