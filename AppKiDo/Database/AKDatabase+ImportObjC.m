//
//  AKDatabase+ObjectiveC.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKBehaviorToken.h"
#import "AKBindingToken.h"
#import "AKCategoryToken.h"
#import "AKClassDeclarationInfo.h"
#import "AKClassToken.h"
#import "AKClassMethodToken.h"
#import "AKFramework.h"
#import "AKHeaderScanner.h"
#import "AKInstanceMethodToken.h"
#import "AKNamedObjectGroup.h"
#import "AKPropertyToken.h"
#import "AKProtocolToken.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "AKInferredTokenInfo.h"
#import "DIGSLog.h"

@implementation AKDatabase (ImportObjC)

- (void)_importObjectiveCTokens
{
	// Before we scan the docset index, scan header files to get a complete
	// class hierarchy.  The docset index doesn't give the complete ancestry for
	// all classes (e.g. DOMElement).
	[self _scanFrameworkHeaderFilesForClassDeclarations];

	// Import tokens with protocol as their token type.
	[self _importProtocols];

	// Import tokens whose token type correctly indicates they are classes, and
	// collect the ones that mistakenly have that token type when they are
	// actually categories.
	NSArray *mistakenTokenMOs = [self _importClassesAndReturnCategoriesMistakenlyLabeledAsClasses];

	// Import tokens we've identified as categories, some of which may actually
	// be informal protocols.  Of those that are informal protocols, some may
	// already have been imported during the _importProtocols phase.
	[self _importCategoriesIncludingMistakenlyLabeled:mistakenTokenMOs];

	// Import methods, properties, and bindings, associating each with the
	// protocol, class, or category it belongs to.
	[self _importClassMethods];
	[self _importInstanceMethods];
	[self _importProperties];
	[self _importBindings];
	[self _importProtocolClassMethods];
	[self _importProtocolInstanceMethods];
	[self _importProtocolProperties];
}

- (void)_scanFrameworkHeaderFilesForClassDeclarations
{
	AKHeaderScanner *scanner = [[AKHeaderScanner alloc] initWithSDKBasePath:self.sdkBasePath];
	NSArray *classDeclarations = [scanner scanHeadersForClassDeclarations];
	for (AKClassDeclarationInfo *classInfo in classDeclarations) {
		// The framework.
		(void)[self _frameworkWithNameAddIfAbsent:classInfo.frameworkName];

		// The subclass.
		AKClassToken *classToken = [self _getOrAddClassTokenWithName:classInfo.nameOfClass];
		classToken.frameworkName = classInfo.frameworkName;
		if (!classInfo.headerPathIsRelativeToSDK) {
			classToken.fullHeaderPathOutsideOfSDK = classInfo.headerPath;
		}

		// The superclass.
		AKClassToken *superclassToken = [self _getOrAddClassTokenWithName:classInfo.nameOfSuperclass];
		[superclassToken addChildClass:classToken];
	}
}

#pragma mark - Protocols

- (void)_importProtocols
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"intf"]) {
		// Require that we identify the framework the protocol belongs to.
		AKFramework *framework = [self _frameworkForTokenMOAddIfAbsent:tokenMO];
		if (framework == nil) {
			continue;
		}

		// Create the protocol token.
		AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:tokenMO.tokenName];
		protocolToken.frameworkName = framework.name;
		protocolToken.tokenMO = tokenMO;

		// Add it to the framework.
		[framework.protocolsGroup addNamedObject:protocolToken];
	}
}

#pragma mark - Classes

- (NSArray *)_importClassesAndReturnCategoriesMistakenlyLabeledAsClasses
{
	NSMutableArray *categoriesMistakenlyLabeledAsClasses = [NSMutableArray array];
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"cl"]) {
		// Workaround for a bug in the 10.11.4 docset.  It contains tokens with
		// token type "cl" but whose token names indicate that they are category
		// tokens, not class tokens, e.g. "NSObject(NSFontPanelValidationAdditions)".
		// Calling _parsePossibleCategoryName: also catches another docset bug;
		// see comments there for explanation.
		NSDictionary *captureGroups = [self _parsePossibleCategoryName:tokenMO.tokenName];
		if (captureGroups[@2]) {
			[categoriesMistakenlyLabeledAsClasses addObject:tokenMO];
			continue;
		}

		// Require that we identify the framework the class belongs to.
		AKFramework *framework = [self _frameworkForTokenMOAddIfAbsent:tokenMO];
		if (framework == nil) {
			continue;
		}

		// Create the class token.
		AKClassToken *classToken = [self _getOrAddClassTokenWithName:tokenMO.tokenName];
		classToken.frameworkName = framework.name;
		classToken.tokenMO = tokenMO;

		// Fill in its superclassToken.
		[self _fillInSuperclassTokenForClassToken:classToken];
	}
	return categoriesMistakenlyLabeledAsClasses;
}

// We get the superclass name from superclassContainers.  If we haven't already
// imported a class with that name, we create a class token using just the name,
// hoping we will be able to fill in the rest later.
- (void)_fillInSuperclassTokenForClassToken:(AKClassToken *)classToken
{
	NSParameterAssert(classToken.tokenMO != nil);
	if (classToken.parentClass) {
		//QLog(@"+++ Class token %@ already has superclass token %@", classToken.name, classToken.parentClass.name);
		return;
	}
	if (classToken.tokenMO.superclassContainers.count > 1) {
		QLog(@"%s [ODD] Unexpected multiple superclassContainers for class %@", __PRETTY_FUNCTION__, classToken.name);
	}
	Container *container = classToken.tokenMO.superclassContainers.anyObject;
	if (container) {
		NSString *superclassName = container.containerName;
		AKClassToken *superclassToken = [self _getOrAddClassTokenWithName:superclassName];
		[superclassToken addChildClass:classToken];
	}
}

#pragma mark - Categories

- (void)_importCategoriesIncludingMistakenlyLabeled:(NSArray *)mistakenlyLabeledCategories
{
	// Import categories that mistakenly had "cl" as their token type.
	for (DSAToken *tokenMO in mistakenlyLabeledCategories) {
		QLog(@"+++ [RADAR] Category whose token type is mistakenly 'cl': %@.", tokenMO.tokenName);
		[self _importWhateverWithCategoryTokenMO:tokenMO];
	}

	// Import categories that correctly have "cat" as their token type.
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"cat"]) {
		[self _importWhateverWithCategoryTokenMO:tokenMO];
	}
}

// May import either a category token or a protocol token, if the category is
// inferred to be an informal protocol.  Assumes we've already called _importProtocols.
//
// Expects tokenMO.tokenName to have one of these forms, and imports nothing otherwise:
// - CLASSNAME(CATEGORYNAME).  Imports a category token, creating it if necessary.
// - CLASSNAME(INFORMALPROTOCOLNAME).  Imports a protocol token, creating it if necessary.
- (void)_importWhateverWithCategoryTokenMO:(DSAToken *)tokenMO
{
	// Require that we be able to figure out what framework the token belongs to.
	NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
	if (frameworkName == nil) {
		return;
	}

	// Try to parse a class name and category name from the token name.
	NSDictionary *captureGroups = [self _parsePossibleCategoryName:tokenMO.tokenName];
	NSString *owningClassName = captureGroups[@1];
	NSString *categoryName = captureGroups[@2];

	// Case: Failed to parse.
	if ((owningClassName == nil) || (categoryName == nil)) {
		QLog(@"+++ [ODD] Expected '%@' to include a class name and category name; will skip this token.", tokenMO.tokenName);
		return;
	}

	// Case: Category is actually an informal protocol.
	if ([self protocolWithName:categoryName]) {
		return;
	}
	if ([tokenMO.parentNode.kName hasSuffix:@"Protocol Reference"]
		|| [categoryName hasSuffix:@"Delegate"]
		|| [categoryName hasSuffix:@"DataSource"])
	{
		QLog(@"+++ Category '%@' is an informal protocol.", categoryName);
		AKFramework *framework = [self _frameworkWithNameAddIfAbsent:frameworkName];
		AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:categoryName];
		protocolToken.tokenMO = tokenMO;
		protocolToken.frameworkName = frameworkName;
		[framework.protocolsGroup addNamedObject:protocolToken];
		return;
	}

	// Case 4: Category is just a category.
	AKClassToken *classToken = [self _getOrAddClassTokenWithName:owningClassName];
	AKCategoryToken *categoryToken = [classToken categoryNamed:categoryName];
	if (categoryToken == nil) {
		categoryToken = [[AKCategoryToken alloc] initWithName:categoryName];
		[classToken addCategory:categoryToken];
		categoryToken.tokenMO = tokenMO;
		categoryToken.frameworkName = frameworkName;
		//QLog(@"+++ Added category '%@(%@)', doc at '%@'.", owningClassName, categoryName, tokenMO.metainformation.file.path);
	}
}

#pragma mark - Members of classes and protocols

- (void)_importClassMethods
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"clm"]) {
		AKBehaviorToken *behaviorToken = [self _ownerOfClassMemberTokenMO:tokenMO];
		if (behaviorToken) {
			AKClassMethodToken *methodToken = [[AKClassMethodToken alloc] initWithTokenMO:tokenMO];
			[behaviorToken addClassMethod:methodToken];
		}
	}
}

- (void)_importInstanceMethods
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"instm"]) {
		AKBehaviorToken *behaviorToken = [self _ownerOfClassMemberTokenMO:tokenMO];
		if (behaviorToken) {
			AKInstanceMethodToken *methodToken = [[AKInstanceMethodToken alloc] initWithTokenMO:tokenMO];
			[behaviorToken addInstanceMethod:methodToken];
		}
	}
}

- (void)_importProperties
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"instp"]) {
		AKBehaviorToken *behaviorToken = [self _ownerOfClassMemberTokenMO:tokenMO];
		if (behaviorToken) {
			AKPropertyToken *propertyToken = [[AKPropertyToken alloc] initWithTokenMO:tokenMO];
			[behaviorToken addPropertyToken:propertyToken];
		}
	}
}

- (void)_importBindings
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"binding"]) {
		if (tokenMO.container.containerName == nil) {
			QLog(@"+++ [ODD] Can't figure out binding's owning class from parent node '%@', container '%@'.", tokenMO.parentNode.kName, tokenMO.container.containerName);
			continue;
		}
		AKClassToken *classToken = [self _getOrAddClassTokenWithName:tokenMO.container.containerName];
		AKBindingToken *bindingToken = [[AKBindingToken alloc] initWithTokenMO:tokenMO];
		[classToken addBindingToken:bindingToken];
	}
}

// May return either a protocol token (when the member belongs to a class
// category that we treat as a protocol) or a class token (all other cases).
- (AKBehaviorToken *)_ownerOfClassMemberTokenMO:(DSAToken *)tokenMO
{
	if (tokenMO.metainformation.file.path == nil) {
		QLog(@"+++ [ODD] Member token '%@' doesn't point to any documentation.", tokenMO.tokenName);  //TODO: Handle this case.
	}


	
	AKBehaviorToken *behaviorToken;
	AKInferredTokenInfo *inferredInfo = [[AKInferredTokenInfo alloc] initWithTokenMO:tokenMO];

	if (inferredInfo.nameOfClass) {
		behaviorToken = [self _getOrAddClassTokenWithName:inferredInfo.nameOfClass];
	} else if (inferredInfo.nameOfProtocol) {
		behaviorToken = [self _getOrAddProtocolTokenWithName:inferredInfo.nameOfProtocol];
	}

	if (behaviorToken == nil) {
		QLog(@"+++ [ODD] Can't figure out owner from parent node '%@', container '%@'.", tokenMO.parentNode.kName, tokenMO.container.containerName);
	}

	return behaviorToken;
}

#pragma mark - Methods owned by protocols

- (void)_importProtocolClassMethods
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"intfcm"]) {
		AKProtocolToken *protocolToken = [self _ownerOfProtocolMemberTokenMO:tokenMO];
		if (protocolToken) {
			AKClassMethodToken *methodToken = [[AKClassMethodToken alloc] initWithTokenMO:tokenMO];
			[protocolToken addClassMethod:methodToken];
		}
	}
}

- (void)_importProtocolInstanceMethods
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"intfm"]) {
		AKProtocolToken *protocolToken = [self _ownerOfProtocolMemberTokenMO:tokenMO];
		if (protocolToken) {
			AKInstanceMethodToken *methodToken = [[AKInstanceMethodToken alloc] initWithTokenMO:tokenMO];
			[protocolToken addInstanceMethod:methodToken];
		}
	}
}

- (void)_importProtocolProperties
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"intfp"]) {
		AKProtocolToken *protocolToken = [self _ownerOfProtocolMemberTokenMO:tokenMO];
		if (protocolToken) {
			AKPropertyToken *propertyToken = [[AKPropertyToken alloc] initWithTokenMO:tokenMO];
			[protocolToken addPropertyToken:propertyToken];
		}
	}
}

- (AKProtocolToken *)_ownerOfProtocolMemberTokenMO:(DSAToken *)tokenMO
{
	if (tokenMO.metainformation.file.path == nil) {
		QLog(@"+++ [ODD] Protocol member token '%@' doesn't point to any documentation.", tokenMO.tokenName);  //TODO: Handle this case.
	}



	AKProtocolToken *protocolToken;
	AKInferredTokenInfo *inferredInfo = [[AKInferredTokenInfo alloc] initWithTokenMO:tokenMO];

	if (inferredInfo.nameOfProtocol) {
		protocolToken = [self _getOrAddProtocolTokenWithName:inferredInfo.nameOfProtocol];
	}

	// Workaround for the fact that some protocol tokens have "XXX Class Reference"
	// in their parent node names.
	if (protocolToken == nil) {
		if (inferredInfo.nameOfClass) {
			protocolToken = [self _getOrAddProtocolTokenWithName:inferredInfo.nameOfClass];
		}
	}

	if (protocolToken == nil) {
		QLog(@"+++ [ODD] Can't figure out protocol from parent node '%@', container '%@'.", tokenMO.parentNode.kName, tokenMO.container.containerName);
	}

	return protocolToken;
}

#pragma mark - Get or add a token given only the name

- (AKProtocolToken *)_getOrAddProtocolTokenWithName:(NSString *)protocolName
{
	AKProtocolToken *protocolToken = self.protocolTokensByName[protocolName];
	if (protocolToken == nil) {
		protocolToken = [[AKProtocolToken alloc] initWithName:protocolName];
		self.protocolTokensByName[protocolName] = protocolToken;
	}
	return protocolToken;
}

- (AKClassToken *)_getOrAddClassTokenWithName:(NSString *)className
{
//	if ([className isEqualToString:@"UINavigationController"]) {
//		[self self];
//	}
//	if ([className isEqualToString:@"GKMatchmakerViewController"]) {
//		[self self];
//	}
//	if ([className isEqualToString:@"NEHotspotNetwork"]) {
//		[self self];
//	}
	if ([className isEqualToString:@"DRFile(VirtualFiles)"]) {
		[self self];
	}


	
	AKClassToken *classToken = self.classTokensByName[className];
	if (classToken == nil) {
		classToken = [[AKClassToken alloc] initWithName:className];
		self.classTokensByName[className] = classToken;
	}
	return classToken;
}

// The returned dictionary will have one of the following forms:
// - @{ @1 : CLASSNAME, @2 : CATEGORYNAME }
// - @{ @1 : CLASSNAME }
// - nil
- (NSDictionary *)_parsePossibleCategoryName:(NSString *)name
{
	// Workaround for a bug/quirk in the 10.11.4 docset.  The token named
	// "NSObjectIOBluetoothHostControllerDelegate" has token type "cl" but
	// is actually a category on NSObject.
	if ([name isEqualToString:@"NSObjectIOBluetoothHostControllerDelegate"]) {
		return @{ @1: @"NSObject",
				  @2: @"IOBluetoothHostControllerDelegate" };
	}

	// Use a regex to parse the class name and category name.
	static NSRegularExpression *s_regexForCategoryNames;
	static dispatch_once_t once;
	dispatch_once(&once,^{
		s_regexForCategoryNames = [AKRegexUtils constructRegexWithPattern:@"(%ident%)(?:\\((%ident%)\\))?"].object;
		NSAssert(s_regexForCategoryNames != nil, @"%s Failed to construct regex.", __PRETTY_FUNCTION__);
	});
	AKResult *result = [AKRegexUtils matchRegex:s_regexForCategoryNames toEntireString:name];
	NSDictionary *captureGroups = result.object;
	return captureGroups;
}

@end
