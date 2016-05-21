//
//  AKDatabase+ObjectiveC.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"
#import "AKBehaviorToken.h"
#import "AKBindingToken.h"
#import "AKCategoryToken.h"
#import "AKClassToken.h"
#import "AKClassMethodToken.h"
#import "AKFramework.h"
#import "AKInstanceMethodToken.h"
#import "AKNamedObjectGroup.h"
#import "AKPropertyToken.h"
#import "AKProtocolToken.h"
#import "AKRegexUtils.h"
#import "AKResult.h"

@implementation AKDatabase (PrivateObjC)

- (void)_importObjectiveCTokens
{
	for (DSAToken *tokenMO in [self _arrayWithTokenMOsForLanguage:@"Objective-C"]) {
		AKToken *token = [self _maybeImportObjectiveCToken:tokenMO];
		if (token == nil) {
			QLog(@"+++ [ODD] Could not import tokenMO %@, type %@", tokenMO.tokenName, tokenMO.tokenType.typeName);
			continue;
		}

		token.tokenMO = tokenMO;
		NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
		if (frameworkName == nil) {
			//QLog(@"+++ Could not infer framework name for tokenMO %@, type %@", tokenMO.tokenName, tokenMO.tokenType.typeName);
		}
		token.frameworkName = frameworkName;
	}
}

- (AKToken *)_maybeImportObjectiveCToken:(DSAToken *)tokenMO
{
	return ([self _maybeImportClassOrCategoryToken:tokenMO]
			?: [self _maybeImportClassMethodToken:tokenMO]
			?: [self _maybeImportInstanceMethodToken:tokenMO]
			?: [self _maybeImportPropertyToken:tokenMO]
			?: [self _maybeImportBindingToken:tokenMO]
			?: [self _maybeImportProtocolToken:tokenMO]
			?: [self _maybeImportProtocolClassMethodToken:tokenMO]
			?: [self _maybeImportProtocolInstanceMethodToken:tokenMO]
			?: [self _maybeImportProtocolPropertyToken:tokenMO]);
}

#pragma mark - Classes and categories

- (AKToken *)_maybeImportClassOrCategoryToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"cl"]
		&& ![tokenMO.tokenType.typeName isEqualToString:@"cat"]) {

		return nil;
	}

	AKBehaviorToken *item = [self _getOrAddClassOrCategoryTokenWithName:tokenMO.tokenName];
	if (item.tokenMO) {
		QLog(@"+++ [ODD] %s item %@ already has a tokenMO", __PRETTY_FUNCTION__, item);
	}
	item.tokenMO = tokenMO;
	if (item.isClassToken) {
		if (((AKClassToken *)item).parentClass == nil) {
			[self _fillInParentClassOfClassToken:((AKClassToken *)item)];
		}
	}
	return item;
}

- (NSRegularExpression *)_regexForCategoryNames
{
	static NSRegularExpression *s_regexForCategoryNames;
	static dispatch_once_t once;
	dispatch_once(&once,^{
		s_regexForCategoryNames = [AKRegexUtils constructRegexWithPattern:@"(%ident%)(?:\\((%ident%)\\))?"].object;
		NSAssert(s_regexForCategoryNames != nil, @"%s Failed to construct regex.", __PRETTY_FUNCTION__);
	});
	return s_regexForCategoryNames;
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
	AKResult *result = [AKRegexUtils matchRegex:[self _regexForCategoryNames] toEntireString:name];
	NSDictionary *captureGroups = result.object;
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
		self.classTokensByName[className] = classToken;
		//QLog(@"+++ class '%@', no token yet", classToken.tokenName);
	}
	return classToken;
}

- (void)_fillInParentClassOfClassToken:(AKClassToken *)classToken
{
	if (classToken.parentClass) {
		QLog(@"+++ Item for class %@ already has parent class %@", classToken.name, classToken.parentClass.name);
		return;
	}
	if (classToken.tokenMO.superclassContainers.count > 1) {
		QLog(@"%s [ODD] Unexpected multiple inheritance for class %@", __PRETTY_FUNCTION__, classToken.name);
	}
	Container *container = classToken.tokenMO.superclassContainers.anyObject;
	if (container) {
		AKClassToken *parentClassToken = [self _getOrAddClassTokenWithName:container.containerName];
		[parentClassToken addChildClass:classToken];
		//QLog(@"+++ parent class '%@' => child class '%@'", parentClassToken.tokenName, classToken.tokenName);
	}
}

- (AKToken *)_maybeImportClassMethodToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"clm"]) {
		return nil;
	}

	NSString *containerName = tokenMO.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryTokenWithName:containerName];
	AKClassMethodToken *methodToken = [[AKClassMethodToken alloc] initWithTokenMO:tokenMO];
	[behaviorToken addClassMethod:methodToken];
	return methodToken;
}

- (AKToken *)_maybeImportInstanceMethodToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"instm"]) {
		return nil;
	}

	NSString *containerName = tokenMO.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryTokenWithName:containerName];
	AKInstanceMethodToken *methodToken = [[AKInstanceMethodToken alloc] initWithTokenMO:tokenMO];
	[behaviorToken addInstanceMethod:methodToken];
	//QLog(@"+++ added instance method %@ to %@ %@", methodToken.tokenName, [behaviorToken className], containerName);
	return methodToken;
}

- (AKToken *)_maybeImportPropertyToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"instp"]) {
		return nil;
	}

	NSString *containerName = tokenMO.container.containerName;
	AKBehaviorToken *behaviorToken = [self _getOrAddClassOrCategoryTokenWithName:containerName];
	AKPropertyToken *propertyToken = [[AKPropertyToken alloc] initWithTokenMO:tokenMO];
	[behaviorToken addPropertyToken:propertyToken];
	return propertyToken;
}

- (AKToken *)_maybeImportBindingToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"binding"]) {
		return nil;
	}

	NSString *className = tokenMO.container.containerName;
	AKClassToken *classToken = (AKClassToken *)[self _getOrAddClassOrCategoryTokenWithName:className];
	AKBindingToken *bindingToken = [[AKBindingToken alloc] initWithTokenMO:tokenMO];
	[classToken addBindingToken:bindingToken];
	//QLog(@"+++ added binding '%@' to class '%@'", bindingToken.tokenName, classToken.tokenName);
	return bindingToken;
}

#pragma mark - Protocols

- (AKToken *)_maybeImportProtocolToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"intf"]) {
		return nil;
	}

	NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
	if (frameworkName == nil) {
		QLog(@"+++ Could not infer framework name for tokenMO %@, type %@", tokenMO.tokenName, tokenMO.tokenType.typeName);
		return nil;
	}

	AKFramework *framework = [self frameworkWithName:frameworkName];
	if (framework == nil) {
		framework = [[AKFramework alloc] initWithName:frameworkName];
		[self.frameworksGroup addNamedObject:framework];
		QLog(@"+++ Had to create new AKFramework %@ for tokenMO %@, type %@", framework.name, tokenMO.tokenName, tokenMO.tokenType.typeName);
	}

	AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:tokenMO.tokenName];
	[framework.protocolsGroup addNamedObject:protocolToken];
	return protocolToken;
}

- (AKProtocolToken *)_getOrAddProtocolTokenWithName:(NSString *)protocolName
{
	AKProtocolToken *protocolToken = self.protocolTokensByName[protocolName];
	if (protocolToken == nil) {
		protocolToken = [[AKProtocolToken alloc] initWithName:protocolName];
		self.protocolTokensByName[protocolName] = protocolToken;
	}
	return protocolToken;
}

- (AKToken *)_maybeImportProtocolClassMethodToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"intfcm"]) {
		return nil;
	}

	NSString *protocolName = tokenMO.container.containerName;
	AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:protocolName];
	AKClassMethodToken *methodToken = [[AKClassMethodToken alloc] initWithTokenMO:tokenMO];
	[protocolToken addClassMethod:methodToken];
	return methodToken;
}

- (AKToken *)_maybeImportProtocolInstanceMethodToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"intfm"]) {
		return nil;
	}

	NSString *protocolName = tokenMO.container.containerName;
	AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:protocolName];
	AKInstanceMethodToken *methodToken = [[AKInstanceMethodToken alloc] initWithTokenMO:tokenMO];
	[protocolToken addInstanceMethod:methodToken];
	return methodToken;
}

- (AKToken *)_maybeImportProtocolPropertyToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"intfp"]) {
		return nil;
	}

	NSString *propertyName = tokenMO.container.containerName;
	AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:propertyName];
	AKPropertyToken *propertyToken = [[AKPropertyToken alloc] initWithTokenMO:tokenMO];
	[protocolToken addPropertyToken:propertyToken];
	return propertyToken;
}

@end
