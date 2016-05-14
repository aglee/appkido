//
//  AKNamedCollection.m
//  AppKiDo
//
//  Created by Andy Lee on 5/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedCollection.h"

@interface AKNamedCollection ()
@property (copy) NSMutableDictionary *elementsByName;
@end

@implementation AKNamedCollection

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_elementsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark - Getters and setters

- (NSArray *)elementNames
{
	return self.elementsByName.allKeys;
}

- (NSArray *)sortedElementNames
{
	return [self.elementsByName.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *)elements
{
	return self.elementsByName.allValues;
}

- (NSArray *)sortedElements
{
	NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"sortName" ascending:YES];
	return [self.elements sortedArrayUsingDescriptors:@[nameSort]];
}

#pragma mark - Managing elements

- (BOOL)hasElementWithName:(NSString *)name
{
	return ([self elementWithName:name] != nil);
}

- (AKNamedObject *)elementWithName:(NSString *)name
{
	return self.elementsByName[name];
}

- (AKNamedObject *)addElementIfAbsent:(AKNamedObject *)element
{
	NSAssert(element != nil, @"Can't add nil element.");
	NSAssert(element.name != nil, @"Can't add a element with no name.");

	if ([self hasElementWithName:element.name]) {
		return [self elementWithName:element.name];
	} else {
		self.elementsByName[element.name] = element;
		return nil;
	}
}

@end
