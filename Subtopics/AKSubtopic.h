/*
 * AKSubtopic.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNamedObject.h"
#import "AKSubtopicConstants.h"

@protocol AKDocListItem;

/*!
 * Used for items in the subtopic list.  When a subtopic is selected, the
 * selected AKSubtopic provides a list of docListItems that will be used to
 * populate the doc list.
 *
 * Note that .displayName is redeclared as readwrite, so it can be set
 * separately from .name.  It defaults to .name.
 */
@interface AKSubtopic : AKNamedObject

@property (copy) NSString *displayName;
@property (copy, readonly) NSArray *docListItems;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name docListItems:(NSArray *)docListItems NS_DESIGNATED_INITIALIZER;

#pragma mark - Docs

/*! Returns -1 if none found. */
- (NSInteger)indexOfDocWithName:(NSString *)docName;
- (id<AKDocListItem>)docAtIndex:(NSInteger)docIndex;
- (id<AKDocListItem>)docWithName:(NSString *)docName;

@end
