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
	for (DSAToken *tokenMO in [self _arrayWithTokenMOsForLanguage:@"Objective-C"]) {
		if (![self _maybeImportObjectiveCToken:tokenMO]) {
			QLog(@"+++ %s [ODD] Could not import token with type '%@'", __PRETTY_FUNCTION__, tokenMO.tokenType.typeName);
		}
	}
}

- (BOOL)_maybeImportObjectiveCToken:(DSAToken *)tokenMO
{
	return ([self _maybeImportClassOrCategoryToken:tokenMO]
			|| [self _maybeImportClassMethodToken:tokenMO]
			|| [self _maybeImportInstanceMethodToken:tokenMO]
			|| [self _maybeImportPropertyToken:tokenMO]
			|| [self _maybeImportBindingToken:tokenMO]
			|| [self _maybeImportProtocolToken:tokenMO]
			|| [self _maybeImportProtocolClassMethodToken:tokenMO]
			|| [self _maybeImportProtocolInstanceMethodToken:tokenMO]
			|| [self _maybeImportProtocolPropertyToken:tokenMO]);
}

#pragma mark - Classes and categories

- (BOOL)_maybeImportClassOrCategoryToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"cl"]
		&& ![tokenMO.tokenType.typeName isEqualToString:@"cat"]) {

		return NO;
	}

	AKBehaviorToken *item = [self _getOrAddClassOrCategoryTokenWithName:tokenMO.tokenName];
	if (item.isClassToken) {
		item.tokenMO = tokenMO;
		if (((AKClassToken *)item).parentClass == nil) {
			[self _fillInParentClassOfClassToken:((AKClassToken *)item)];
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
- (AKBehaviorToken *)_getOrAddClassOrCategoryTokenWithName:(NSString *)name
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
	AKClassToken *classToken = [self _getOrAddClassTokenWithName:className];
	if (categoryName == nil) {
		return classToken;
	}

	// Case 3: Both a class name and a category name.
	AKCategoryToken *categoryToken = [classToken categoryNamed:categoryName];
	if (categoryToken == nil) {
		categoryToken = [[AKCategoryToken alloc] initWithName:categoryName];
		[classToken addCategory:categoryToken];
		//QLog(@"+++ added category %@ to class %@", categoryName, className);
	}
	return categoryToken;
}

- (AKClassToken *)_getOrAddClassTokenWithName:(NSString *)className
{
	AKClassToken *classToken = self.classTokensByName[className];
	if (classToken == nil) {
		classToken = [[AKClassToken alloc] initWithName:className];
		classToken.fallbackTokenName = className;
		self.classTokensByName[className] = classToken;
		//QLog(@"+++ class '%@', no token yet", classToken.tokenName);
	}
	return classToken;
}

- (void)_fillInParentClassOfClassToken:(AKClassToken *)classToken
{
	if (classToken.parentClass) {
		QLog(@"+++ Item for class %@ already has parent class %@", classToken.tokenName, classToken.parentClass.tokenName);
		return;
	}
	if (classToken.tokenMO.superclassContainers.count > 1) {
		QLog(@"%s [ODD] Unexpected multiple inheritance for class %@", __PRETTY_FUNCTION__, classToken.tokenName);
	}
	Container *container = classToken.tokenMO.superclassContainers.anyObject;
	if (container) {
		AKClassToken *parentClassToken = [self _getOrAddClassTokenWithName:container.containerName];
		[parentClassToken addChildClass:classToken];
		//QLog(@"+++ parent class '%@' => child class '%@'", parentClassToken.tokenName, classToken.tokenName);
	}
}

- (BOOL)_maybeImportClassMethodToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"clm"]) {
		return NO;
	}

	NSString *containerName = tokenMO.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryTokenWithName:containerName];
	AKMethodToken *methodToken = [[AKMethodToken alloc] initWithName:tokenMO.tokenName];
	methodToken.tokenMO = tokenMO;
	[behaviorToken addClassMethod:methodToken];
	return YES;
}

- (BOOL)_maybeImportInstanceMethodToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"instm"]) {
		return NO;
	}

	NSString *containerName = tokenMO.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryTokenWithName:containerName];
	AKMethodToken *methodToken = [[AKMethodToken alloc] initWithName:tokenMO.tokenName];
	methodToken.tokenMO = tokenMO;
	[behaviorToken addInstanceMethod:methodToken];
	//QLog(@"+++ added instance method %@ to %@ %@", methodToken.tokenName, [behaviorToken className], containerName);
	return YES;
}

- (BOOL)_maybeImportPropertyToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"instp"]) {
		return NO;
	}

	NSString *containerName = tokenMO.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryTokenWithName:containerName];
	AKPropertyToken *propertyToken = [[AKPropertyToken alloc] initWithName:tokenMO.tokenName];
	propertyToken.tokenMO = tokenMO;
	[behaviorToken addPropertyToken:propertyToken];
	return YES;
}

- (BOOL)_maybeImportBindingToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"binding"]) {
		return NO;
	}

	NSString *className = tokenMO.container.containerName;
	AKClassToken *classToken = (AKClassToken *)[self _getOrAddClassOrCategoryTokenWithName:className];
	AKBindingToken *bindingToken = [[AKBindingToken alloc] initWithName:tokenMO.tokenName];
	bindingToken.tokenMO = tokenMO;
	[classToken addBindingToken:bindingToken];
	//QLog(@"+++ added binding '%@' to class '%@'", bindingToken.tokenName, classToken.tokenName);
	return YES;
}

#pragma mark - Protocols

- (BOOL)_maybeImportProtocolToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"intf"]) {
		return NO;
	}

	(void)[self _getOrAddProtocolTokenWithTokenMO:tokenMO];
	return YES;
}

- (AKProtocolToken *)_getOrAddProtocolTokenWithTokenMO:(DSAToken *)tokenMO
{
	AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:tokenMO.tokenName];
	if (protocolToken.tokenMO == nil) {
		protocolToken.tokenMO = tokenMO;
		//QLog(@"+++ protocol '%@' has tokenMO, is in framework '%@'", protocolToken.tokenName, protocolToken.frameworkName);
	} else {
		// We don't expect to encounter the same class twice with the same token.
		QLog(@"+++ [ODD] protocol '%@' already has a token", tokenMO.tokenName);
	}
	return protocolToken;
}

- (AKProtocolToken *)_getOrAddProtocolTokenWithName:(NSString *)protocolName
{
	AKProtocolToken *protocolToken = self.protocolTokensByName[protocolName];
	if (protocolToken == nil) {
		protocolToken = [[AKProtocolToken alloc] initWithName:protocolName];
		self.protocolTokensByName[protocolName] = protocolToken;
		//QLog(@"+++ protocol '%@', no token yet", protocolToken.tokenName);
	}
	return protocolToken;
}

- (BOOL)_maybeImportProtocolClassMethodToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"intfcm"]) {
		return NO;
	}

	NSString *protocolName = tokenMO.container.containerName;
	AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:protocolName];
	AKMethodToken *methodToken = [[AKMethodToken alloc] initWithName:tokenMO.tokenName];
	methodToken.tokenMO = tokenMO;
	[protocolToken addClassMethod:methodToken];
	return YES;
}

- (BOOL)_maybeImportProtocolInstanceMethodToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"intfm"]) {
		return NO;
	}

	NSString *protocolName = tokenMO.container.containerName;
	AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:protocolName];
	AKMethodToken *methodToken = [[AKMethodToken alloc] initWithName:tokenMO.tokenName];
	methodToken.tokenMO = tokenMO;
	[protocolToken addInstanceMethod:methodToken];
	return YES;
}

- (BOOL)_maybeImportProtocolPropertyToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"intfp"]) {
		return NO;
	}

	NSString *propertyName = tokenMO.container.containerName;
	AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:propertyName];
	AKPropertyToken *propertyToken = [[AKPropertyToken alloc] initWithName:tokenMO.tokenName];
	propertyToken.tokenMO = tokenMO;
	[protocolToken addPropertyToken:propertyToken];
	return YES;
}

@end
