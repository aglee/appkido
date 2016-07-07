//
// AKClassToken.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKClassToken.h"
#import "DIGSLog.h"
#import "AKBindingToken.h"
#import "AKCategoryToken.h"
#import "AKDatabase.h"
#import "AKMethodToken.h"
#import "AKProtocolToken.h"
#import "NSString+AppKiDo.h"

@interface AKClassToken ()
@property (readwrite, weak) AKClassToken *superclassToken;
@property (readwrite, strong) NSMutableDictionary *delegateProtocolTokensByName;
@property (readwrite, strong) NSMutableDictionary *bindingTokensByName;
@end

@implementation AKClassToken
{
@private
	NSMutableArray *_subclassTokens;
	NSMutableArray *_categoryTokens;
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_subclassTokens = [[NSMutableArray alloc] init];
		_categoryTokens = [[NSMutableArray alloc] init];
		_delegateProtocolTokensByName = [[NSMutableDictionary alloc] init];
		_bindingTokensByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark - Subclass tokens

- (void)addSubclassToken:(AKClassToken *)classToken
{
	// We check for subclass != superclass to avoid circularity.  This
	// doesn't protect against the general case of a cycle, but it does
	// work around the typo in the Tiger docs where the superclass of
	// NSAnimation was given as NSAnimation.
	if (classToken == self) {
		DIGSLogDebug(@"ignoring attempt to make %@ a subclass of itself", self.name);
		return;
	}

	[classToken.superclassToken removeSubclassToken:classToken];
	classToken.superclassToken = self;
	[_subclassTokens addObject:classToken];
}

- (void)removeSubclassToken:(AKClassToken *)classToken
{
	NSInteger i = [_subclassTokens indexOfObject:classToken];
	if (i >= 0) {
		classToken.superclassToken = nil;
		[_subclassTokens removeObjectAtIndex:i];
	}
}

- (NSArray *)subclassTokens
{
	return _subclassTokens;
}

- (NSSet *)descendantClassTokens
{
	NSMutableSet *descendantClassTokens = [NSMutableSet setWithCapacity:50];
	[self _addDescendantClassTokensToSet:descendantClassTokens];
	return descendantClassTokens;
}

#pragma mark - Category tokens

- (AKCategoryToken *)categoryTokenWithName:(NSString *)name
{
	for (AKCategoryToken *token in _categoryTokens) {
		if ([token.name isEqualToString:name]) {
			return token;
		}
	}
	return nil;
}

- (void)addCategoryToken:(AKCategoryToken *)token
{
	[token.owningClassToken removeCategoryToken:token];
	[_categoryTokens addObject:token];
	token.owningClassToken = self;
}

- (void)removeCategoryToken:(AKCategoryToken *)token
{
	NSInteger i = [_subclassTokens indexOfObject:token];
	if (i >= 0) {
		token.owningClassToken = nil;
		[_categoryTokens removeObjectAtIndex:i];
	}
}

- (NSArray *)categoryTokensImmediateOnly
{
	return _categoryTokens;
}

- (NSArray *)categoryTokensIncludingInherited
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:_categoryTokens];

	// Get categories from ancestor classes.
	if (self.superclassToken) {
		[result addObjectsFromArray:self.superclassToken.categoryTokensIncludingInherited];
	}

	return result;
}

#pragma mark - Bindings tokens

- (void)addBindingToken:(AKToken *)bindingToken
{
	self.bindingTokensByName[bindingToken.name] = bindingToken;
}

- (AKToken *)bindingTokenWithName:(NSString *)name
{
	return self.bindingTokensByName[name];
}

- (NSArray *)bindingTokens
{
	return self.bindingTokensByName.allValues;
}

#pragma mark - Delegate method tokens

- (BOOL)hasDelegate
{
	return (self.delegateProtocolTokensByName.count > 0);
}

- (NSArray *)delegateMethodTokens
{
	NSMutableArray *delegateMethodTokens = [NSMutableArray array];

	for (AKProtocolToken *delegateProtocolToken in self.delegateProtocolTokensByName.allValues) {
		[delegateMethodTokens addObjectsFromArray:delegateProtocolToken.classMethodTokens];
		[delegateMethodTokens addObjectsFromArray:delegateProtocolToken.instanceMethodTokens];
	}

	return delegateMethodTokens;
}

- (void)addDelegateProtocolToken:(AKProtocolToken *)delegateProtocolToken
{
	self.delegateProtocolTokensByName[delegateProtocolToken.name] = delegateProtocolToken;
	delegateProtocolToken.isDelegateProtocolToken = YES;
}

- (NSArray *)delegateProtocolTokens
{
	return self.delegateProtocolTokensByName.allValues;
}

#pragma mark - AKBehaviorToken methods

- (BOOL)isClassToken
{
	return YES;
}

- (NSArray *)adoptedProtocolTokens
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:[super adoptedProtocolTokens]];

	// Get protocols from ancestor classes.
	[result addObjectsFromArray:self.superclassToken.adoptedProtocolTokens];

	return result;
}

- (BOOL)hasContent
{
	return (super.hasContent
			|| self.delegateProtocolTokensByName.count > 0
			|| self.bindingTokensByName.count > 0
			|| _subclassTokens.count > 0
			|| _categoryTokens.count > 0);
}

- (void)tearDown
{
	[super tearDown];

	[self.superclassToken removeSubclassToken:self];
	[self.delegateProtocolTokensByName removeAllObjects];
	[self.bindingTokensByName removeAllObjects];
	[_subclassTokens removeAllObjects];
	[_categoryTokens removeAllObjects];
}

#pragma mark - Private methods

- (void)_addDescendantClassTokensToSet:(NSMutableSet *)descendantClassTokens
{
	[descendantClassTokens addObject:self];
	for (AKClassToken *subclassToken in _subclassTokens) {
		[subclassToken _addDescendantClassTokensToSet:descendantClassTokens];
	}
}

@end
