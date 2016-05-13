//
//  AKDatabase+ObjectiveC.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"

@implementation AKDatabase (PrivateObjC)

- (void)_importObjectiveCTokens
{
	for (DSAToken *token in [self _arrayWithTokensForLanguage:@"Objective-C"]) {
		if (![self _maybeImportObjectiveCToken:token]) {
			QLog(@"+++ %s [ODD] Could not import token with type '%@'", __PRETTY_FUNCTION__, token.tokenType.typeName);
		}
	}
}

- (BOOL)_maybeImportObjectiveCToken:(DSAToken *)token
{
	return ([self _maybeImportClassOrCategoryToken:token]
			|| [self _maybeImportClassMethodToken:token]
			|| [self _maybeImportInstanceMethodToken:token]
			|| [self _maybeImportPropertyToken:token]
			|| [self _maybeImportBindingToken:token]
			|| [self _maybeImportProtocolToken:token]
			|| [self _maybeImportProtocolClassMethodToken:token]
			|| [self _maybeImportProtocolInstanceMethodToken:token]
			|| [self _maybeImportProtocolPropertyToken:token]);
}

#pragma mark - Classes and categories

- (BOOL)_maybeImportClassOrCategoryToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"cl"]
		&& ![token.tokenType.typeName isEqualToString:@"cat"]) {

		return NO;
	}

	AKBehaviorToken *item = [self _getOrAddClassOrCategoryItemWithName:token.tokenName];
	if (item.isClassItem) {
		item.tokenMO = token;
		if (((AKClassItem *)item).parentClass == nil) {
			[self _fillInParentClassOfClassItem:((AKClassItem *)item)];
		}
	}
	return YES;
}

// The contorted logic here is a workaround for what looks like a bug in the
// 10.11.4 docset.  It contains tokens that are marked as classes (token type
// "cl"), where that is clearly an error, because their names have the form of
// category names, e.g. "NSObject(NSFontPanelValidationAdditions)".  So rather
// than trust the token type, this method goes by the token name to decide what
// kind of token it is.
- (AKBehaviorToken *)_getOrAddClassOrCategoryItemWithName:(NSString *)name
{
	// AFAICT the tokenName for a category token always has the form
	// "ClassName(CategoryName)" -- except in the case of
	// NSObjectIOBluetoothHostControllerDelegate, which has token type "cl" but
	// is a category on NSObject (as the docs for it say).  Hence this kludge.
	// TODO: File a Radar.
	if ([name isEqualToString:@"NSObjectIOBluetoothHostControllerDelegate"]) {
		name = @"NSObject(IOBluetoothHostControllerDelegate)";
	}

	// Try to parse a class name and category name from the token name.
	NSDictionary *captureGroups = [AKRegexUtils matchPattern:@"(%ident%)(?:\\((%ident%)\\))?" toEntireString:name];
	NSString *className = captureGroups[@1];
	NSString *categoryName = captureGroups[@2];

	// Case 1: No class name (pathological case).
	if (className == nil) {
		QLog(@"+++ [ODD] '%@' doesn't look like either a class or a category; will skip this token.", name);
		return nil;
	}

	// Case 2: Only a class name.
	AKClassItem *classItem = [self _getOrAddClassItemWithName:className];
	if (categoryName == nil) {
		return classItem;
	}

	// Case 3: Both a class name and a category name.
	AKCategoryItem *categoryItem = [classItem categoryNamed:categoryName];
	if (categoryItem == nil) {
		categoryItem = [[AKCategoryItem alloc] initWithToken:nil];
		[classItem addCategory:categoryItem];
		//QLog(@"+++ added category %@ to class %@", categoryName, className);
	}
	return categoryItem;
}

- (AKClassItem *)_getOrAddClassItemWithName:(NSString *)className
{
	AKClassItem *classItem = self.classItemsByName[className];
	if (classItem == nil) {
		classItem = [[AKClassItem alloc] initWithToken:nil];
		classItem.fallbackTokenName = className;
		self.classItemsByName[className] = classItem;
		//QLog(@"+++ class '%@', no token yet", classItem.tokenName);
	}
	return classItem;
}

- (void)_fillInParentClassOfClassItem:(AKClassItem *)classItem
{
	if (classItem.parentClass) {
		QLog(@"+++ Item for class %@ already has parent class %@", classItem.tokenName, classItem.parentClass.tokenName);
		return;
	}
	if (classItem.tokenMO.superclassContainers.count > 1) {
		QLog(@"%s [ODD] Unexpected multiple inheritance for class %@", __PRETTY_FUNCTION__, classItem.tokenName);
	}
	Container *container = classItem.tokenMO.superclassContainers.anyObject;
	if (container) {
		AKClassItem *parentClassItem = [self _getOrAddClassItemWithName:container.containerName];
		[parentClassItem addChildClass:classItem];
		//QLog(@"+++ parent class '%@' => child class '%@'", parentClassItem.tokenName, classItem.tokenName);
	}
}

- (BOOL)_maybeImportClassMethodToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"clm"]) {
		return NO;
	}

	NSString *containerName = token.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryItemWithName:containerName];
	AKMethodItem *methodItem = [[AKMethodItem alloc] initWithToken:token owningBehavior:behaviorToken];
	[behaviorToken addClassMethod:methodItem];
	return YES;
}

- (BOOL)_maybeImportInstanceMethodToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"instm"]) {
		return NO;
	}

	NSString *containerName = token.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryItemWithName:containerName];
	AKMethodItem *methodItem = [[AKMethodItem alloc] initWithToken:token owningBehavior:behaviorToken];
	[behaviorToken addInstanceMethod:methodItem];
	//QLog(@"+++ added instance method %@ to %@ %@", methodItem.tokenName, [behaviorToken className], containerName);
	return YES;
}

- (BOOL)_maybeImportPropertyToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"instp"]) {
		return NO;
	}

	NSString *containerName = token.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryItemWithName:containerName];
	AKPropertyItem *propertyItem = [[AKPropertyItem alloc] initWithToken:token owningBehavior:behaviorToken];
	[behaviorToken addPropertyItem:propertyItem];
	return YES;
}

- (BOOL)_maybeImportBindingToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"binding"]) {
		return NO;
	}

	NSString *className = token.container.containerName;
	AKClassItem *classItem = (AKClassItem *)[self _getOrAddClassOrCategoryItemWithName:className];
	AKBindingItem *bindingItem = [[AKBindingItem alloc] initWithToken:token owningBehavior:classItem];
	[classItem addBindingItem:bindingItem];
	//QLog(@"+++ added binding '%@' to class '%@'", bindingItem.tokenName, classItem.tokenName);
	return YES;
}

#pragma mark - Protocols

- (BOOL)_maybeImportProtocolToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"intf"]) {
		return NO;
	}

	(void)[self _getOrAddProtocolItemWithToken:token];
	return YES;
}

- (AKProtocolItem *)_getOrAddProtocolItemWithToken:(DSAToken *)token
{
	AKProtocolItem *protocolItem = [self _getOrAddProtocolItemWithName:token.tokenName];
	if (protocolItem.tokenMO == nil) {
		protocolItem.tokenMO = token;
		//QLog(@"+++ protocol '%@' has token, is in framework '%@'", protocolItem.tokenName, protocolItem.frameworkName);
	} else {
		// We don't expect to encounter the same class twice with the same token.
		QLog(@"+++ [ODD] protocol '%@' already has a token", token.tokenName);
	}
	return protocolItem;
}

- (AKProtocolItem *)_getOrAddProtocolItemWithName:(NSString *)protocolName
{
	AKProtocolItem *protocolItem = self.protocolItemsByName[protocolName];
	if (protocolItem == nil) {
		protocolItem = [[AKProtocolItem alloc] initWithToken:nil];
		self.protocolItemsByName[protocolName] = protocolItem;
		//QLog(@"+++ protocol '%@', no token yet", protocolItem.tokenName);
	}
	return protocolItem;
}

- (BOOL)_maybeImportProtocolClassMethodToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"intfcm"]) {
		return NO;
	}

	NSString *protocolName = token.container.containerName;
	AKProtocolItem *protocolItem = [self _getOrAddProtocolItemWithName:protocolName];
	AKMethodItem *methodItem = [[AKMethodItem alloc] initWithToken:token owningBehavior:protocolItem];
	[protocolItem addClassMethod:methodItem];
	return YES;
}

- (BOOL)_maybeImportProtocolInstanceMethodToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"intfm"]) {
		return NO;
	}

	NSString *protocolName = token.container.containerName;
	AKProtocolItem *protocolItem = [self _getOrAddProtocolItemWithName:protocolName];
	AKMethodItem *methodItem = [[AKMethodItem alloc] initWithToken:token owningBehavior:protocolItem];
	[protocolItem addInstanceMethod:methodItem];
	return YES;
}

- (BOOL)_maybeImportProtocolPropertyToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"intfp"]) {
		return NO;
	}

	NSString *propertyName = token.container.containerName;
	AKProtocolItem *protocolItem = [self _getOrAddProtocolItemWithName:propertyName];
	AKPropertyItem *propertyItem = [[AKPropertyItem alloc] initWithToken:token owningBehavior:protocolItem];
	[protocolItem addPropertyItem:propertyItem];
	return YES;
}

@end
