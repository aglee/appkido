/*
 * AKSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"
#import "DIGSLog.h"
#import "AKDocListItem.h"

@implementation AKSubtopic

@synthesize displayName = _displayName;
@synthesize docListItems = _docListItems;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name docListItems:(NSArray *)docListItems
{
	self = [super initWithName:name];
	if (self) {
		_displayName = name;
		_docListItems = docListItems;
	}
	return self;
}

- (instancetype)initWithName:(NSString *)name
{
	return [self initWithName:name docListItems:nil];
}

#pragma mark - <AKSubtopicListItem> methods

- (NSInteger)indexOfDocWithName:(NSString *)docName
{
	if (docName == nil) {
		return -1;
	}

	NSInteger numDocs = self.docListItems.count;
	NSInteger i;
	for (i = 0; i < numDocs; i++) {
		id<AKDocListItem> doc = self.docListItems[i];
		if ([doc.name isEqualToString:docName]) {
			return i;
		}
	}

	// If we got this far, the search failed.
	return -1;
}

- (id<AKDocListItem>)docAtIndex:(NSInteger)docIndex
{
	return (docIndex < 0) ? nil : self.docListItems[docIndex];
}

- (id<AKDocListItem>)docWithName:(NSString *)docName
{
	return [self docAtIndex:[self indexOfDocWithName:docName]];
}

@end
