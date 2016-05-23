/*
 * AKSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"
#import "DIGSLog.h"
#import "AKDoc.h"

@implementation AKSubtopic

@synthesize docListItems = _docListItems;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name docListItems:(NSArray *)docListItems
{
	self = [super initWithName:name];
	if (self) {
		_docListItems = docListItems;
	}
	return self;
}

- (instancetype)initWithName:(NSString *)name
{
	return [self initWithName:name docListItems:nil];
}

#pragma mark - Accessing doc list items

- (NSInteger)indexOfDocWithName:(NSString *)docName
{
	if (docName == nil) {
		return -1;
	}

	for (NSUInteger i = 0; i < self.docListItems.count; i++) {
		if ([[self docAtIndex:i].name isEqualToString:docName]) {
			return i;
		}
	}

	// If we got this far, the search failed.
	return -1;
}

- (id<AKDoc>)docAtIndex:(NSInteger)docIndex
{
	return (docIndex < 0) ? nil : self.docListItems[docIndex];
}

- (id<AKDoc>)docWithName:(NSString *)docName
{
	return [self docAtIndex:[self indexOfDocWithName:docName]];
}

@end
