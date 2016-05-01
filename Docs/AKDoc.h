/*
 * AKDoc.h
 *
 * Created by Andy Lee on Mon Mar 15 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * Abstract class that encapsulates one of the docs that fall under an
 * AKSubtopic. Depending on the concrete subclass, the doc content might be
 * either HTML or a header file.
 *
 * UI notes: when a doc is selected in the doc list, the selected AKDoc provides
 * the text to display in the doc view, and also the string to display in the
 * comment field at the bottom of the window.
 */
@interface AKDoc : NSObject

#pragma mark - Getters and setters

/*! Subclasses must override. */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL docTextIsHTML;

/*!
 * Subclasses must override.
 *
 * Name used internally by AKDocLocator. Must be unique among all the docs in a
 * given subtopic's doc list.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *docName;

/*! The string to display in the doc list table.  Defaults to self.docName. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringToDisplayInDocList;

/*!
 * The string to display in the comment field at the bottom of the window.
 * Defaults to the empty string.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *commentString;

/*!
 * Subclasses must override.
 *
 * Indicates where the doc content is located.
 */
- (NSURL *)docURLWithBasePath:(NSString *)basePath;

@end
