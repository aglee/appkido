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
#import "AKInferredTokenInfo.h"
#import "AKInstanceMethodToken.h"
#import "AKNamedObjectGroup.h"
#import "AKPropertyToken.h"
#import "AKProtocolToken.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
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

	// Associate delegates with the classes that own them.
	[self _associateDelegateProtocolsWithClasses];
}

- (void)_associateDelegateProtocolsWithClasses
{
	for (AKClassToken *classToken in self.allClassTokens) {
		[self _lookForRegularDelegateOfClassToken:classToken];
		[self _lookForExtraDelegatesOfClassToken:classToken];
	}
	[self _treatToolTipOwnerAsDelegate];
}

// The simplest and most common case: look for a protocol whose name is the
// class name with "Delegate" appended.  For example, if the class is
// NSTableView, we would look for an NSTableViewDelegate protocol.
- (void)_lookForRegularDelegateOfClassToken:(AKClassToken *)classToken
{
	NSString *protocolName = [classToken.name stringByAppendingString:@"Delegate"];
	AKProtocolToken *protocolToken = [self protocolTokenWithName:protocolName];
	if (protocolToken) {
		//QLog(@"+++ Adding regular delegate protocol '%@' to class '%@'.", protocolToken.name, classToken.name);
		[classToken addDelegateProtocolToken:protocolToken];
	}
}

// Some classes have multiple delegates.  We can discover the delegates of those
// delegate as follows, using WebView as an example.
//
// - Consider each property whose name ends with "Delegate".
//   - WebView has downloadDelegate and UIDelegate (among others).
// - Find all protocols in the same framework as the class whose names end with
//   the capitalized property name.
//   - WebKit has a protocol WebDownloadDelegate that has the capitalized suffix
//     "DownloadDelegate".
//   - WebKit has two protocols with th suffix "UIDelegate": WebUIDelegate and
//     WKUIDelegate.
// - Strip the property name from each protocol name to get a prefix.  If the
//   class name has that prefix, conclude that the protocol is a delegate
//   protocol for the class.
//   - "WebDownloadDelegate" minus "DownloadDelegate" is "Web", which is
//     a prefix of "WebView", so we conclude that WebDownloadDelegate is
//     a delegate of WebView.
//   - Similarly, we conclude that "WebUIDelegate" is a delegate of WebView.
//   - "WKUIDelegate" minus "UIDelegate" is "WK", which is not a prefix of
//     "WebView", so we conclude WKUIDelegate is not a delegate of WebView.
//
// I'm assuming delegates are always declared as properties, so I don't have to
// also check for getter and setter methods like xyzDelegate or setXyzDelegate:.
- (void)_lookForExtraDelegatesOfClassToken:(AKClassToken *)classToken
{
	for (AKPropertyToken *propertyToken in classToken.propertyTokens) {
		if (![propertyToken.name hasSuffix:@"Delegate"]) {
			continue;
		}

		AKFramework *framework = [self frameworkWithName:classToken.frameworkName];
		if (framework == nil) {
			QLog(@"+++ [ODD] %s Skipping class '%@' because the framework is unknown.", __PRETTY_FUNCTION__, classToken);
			continue;
		}

		// Capitalize the property name.  Can't simply use capitalizedString,
		// because it changes "UIDelegate" to "Uidelegate".
		NSString *cappedFirstLetter = [propertyToken.name substringToIndex:1].uppercaseString;
		NSString *afterFirstLetter = [propertyToken.name substringFromIndex:1];
		NSString *cappedPropertyName = [cappedFirstLetter stringByAppendingString:afterFirstLetter];
		for (AKProtocolToken *protocolToken in framework.protocolsGroup.objects) {
			if (![protocolToken.name hasSuffix:cappedPropertyName]) {
				continue;
			}

			NSInteger prefixLength = protocolToken.name.length - cappedPropertyName.length;
			NSString *prefix = [protocolToken.name substringToIndex:prefixLength];
			if (![classToken.name hasPrefix:prefix]) {
				continue;
			}

			//QLog(@"+++ Adding extra delegate protocol '%@' to class '%@'.", protocolToken.name, classToken.name);
			[classToken addDelegateProtocolToken:protocolToken];
		}
	}
}

// Hard-coded special case.  To me, NSToolTipOwner is a delegate, so I'm going
// to treat it that way even though the docs don't.
- (void)_treatToolTipOwnerAsDelegate
{
	NSString *toolTipProtocolName = @"NSToolTipOwner";
	NSString *viewClassName = @"NSView";

	AKProtocolToken *toolTipProtocolToken = [self protocolTokenWithName:toolTipProtocolName];
	if (toolTipProtocolToken == nil) {
		return;
	}

	AKClassToken *viewClassToken = [self classTokenWithName:viewClassName];
	if (viewClassToken == nil) {
		QLog(@"+++ [ODD] The protocol '%@' was found but not the class '%@'.", toolTipProtocolName, viewClassName);
		return;
	}

	[viewClassToken addDelegateProtocolToken:toolTipProtocolToken];
}

- (void)_scanFrameworkHeaderFilesForClassDeclarations
{
	AKHeaderScanner *scanner = [[AKHeaderScanner alloc] initWithInstalledSDK:self.referenceSDK];
	NSArray *classDeclarations = [scanner scanHeadersForClassDeclarations];
	for (AKClassDeclarationInfo *classInfo in classDeclarations) {
		// The framework.
		AKFramework *framework = [self _getOrAddFrameworkWithName:classInfo.frameworkName];

		// The subclass.
		AKClassToken *classToken = [self _getOrAddClassTokenWithName:classInfo.nameOfClass];
		classToken.frameworkName = classInfo.frameworkName;
		if (!classInfo.headerPathIsRelativeToSDK) {
			classToken.fullHeaderPathOutsideOfSDK = classInfo.headerPath;
		}
		[framework.classesGroup addNamedObject:classToken];

		// The superclass.
		AKClassToken *superclassToken = [self _getOrAddClassTokenWithName:classInfo.nameOfSuperclass];
		[superclassToken addSubclassToken:classToken];
	}
}

#pragma mark - Protocols

- (void)_importProtocols
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"Objective-C" tokenType:@"intf"]) {
		// Require that we identify the framework the protocol belongs to.
		NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
		AKFramework *framework = [self _getOrAddFrameworkWithName:frameworkName];
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
		// Calling parsePossibleCategoryName: also catches another docset bug;
		// see comments there for explanation.
		NSDictionary *captureGroups = [AKInferredTokenInfo parsePossibleCategoryName:tokenMO.tokenName];
		if (captureGroups[@2]) {
			[categoriesMistakenlyLabeledAsClasses addObject:tokenMO];
			continue;
		}

		// Require that we identify the framework the class belongs to.
		NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
		AKFramework *framework = [self _getOrAddFrameworkWithName:frameworkName];
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
	if (classToken.superclassToken) {
		//QLog(@"+++ Class token %@ already has superclass token %@", classToken.name, classToken.superclassToken.name);
		return;
	}
	if (classToken.tokenMO.superclassContainers.count > 1) {
		QLog(@"%s [ODD] Unexpected multiple superclassContainers for class %@", __PRETTY_FUNCTION__, classToken.name);
	}
	Container *container = classToken.tokenMO.superclassContainers.anyObject;
	if (container) {
		NSString *superclassName = container.containerName;
		AKClassToken *superclassToken = [self _getOrAddClassTokenWithName:superclassName];
		[superclassToken addSubclassToken:classToken];
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
	NSDictionary *captureGroups = [AKInferredTokenInfo parsePossibleCategoryName:tokenMO.tokenName];
	NSString *owningClassName = captureGroups[@1];
	NSString *categoryName = captureGroups[@2];

	// Case: Failed to parse.
	if ((owningClassName == nil) || (categoryName == nil)) {
		QLog(@"+++ [ODD] Expected '%@' to include a class name and category name; will skip this token.", tokenMO.tokenName);
		return;
	}

	// Case: Category is actually an informal protocol.
	// We check for "DelegateMethods" as a suffix to handle cases like
	// "NSObject(DRBurnProgressPanelDelegateMethods)" and
	// "NSObject(DREraseProgressPanelDelegateMethods)".
	if ([self protocolTokenWithName:categoryName]) {
		return;
	}
	if ([tokenMO.parentNode.kName hasSuffix:@"Protocol Reference"]
		|| [categoryName hasSuffix:@"Delegate"]
		|| [categoryName hasSuffix:@"DelegateMethods"]
		|| [categoryName hasSuffix:@"DataSource"])
	{
		//QLog(@"+++ Category '%@' is an informal protocol.", categoryName);
		AKFramework *framework = [self _getOrAddFrameworkWithName:frameworkName];
		AKProtocolToken *protocolToken = [self _getOrAddProtocolTokenWithName:categoryName];
		protocolToken.tokenMO = tokenMO;
		protocolToken.frameworkName = frameworkName;
		[framework.protocolsGroup addNamedObject:protocolToken];
		return;
	}

	// Case 4: Category is just a category.
	AKClassToken *classToken = [self _getOrAddClassTokenWithName:owningClassName];
	AKCategoryToken *categoryToken = [classToken categoryTokenWithName:categoryName];
	if (categoryToken == nil) {
		categoryToken = [[AKCategoryToken alloc] initWithName:categoryName];
		[classToken addCategoryToken:categoryToken];
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

- (AKBehaviorToken *)_ownerOfClassMemberTokenMO:(DSAToken *)tokenMO
{
	if (tokenMO.metainformation.file.path == nil) {
		// Here's an example of why I'm skipping tokens that don't point to a
		// documentation path.  In the iOS 9.3 docset, there are two tokens
		// named attributedStringFromPostalAddress:withDefaultAttributes:.  One
		// is tagged as an instance method of CNPostalAddressFormatter, and
		// points to a doc path.  The other is tagged as a class method, and
		// does not point to a doc path.  Only the instance method token is
		// correct.
		//
		// I suspect at some point somebody noticed the incorrect token
		// entry and added the correct one, but forgot to delete the incorrect
		// one, or had to leave it in for some technical reason.
		//QLog(@"+++ [ODD] Skipping member token '%@', type '%@', container '%@'; it doesn't point to any documentation.", tokenMO.tokenName, tokenMO.tokenType.typeName, tokenMO.container.containerName);
		return nil;
	}

	AKInferredTokenInfo *inferredInfo = [[AKInferredTokenInfo alloc] initWithTokenMO:tokenMO];
	AKBehaviorToken *behaviorToken = [self _behaviorTokenFromInferredInfo:inferredInfo];
	if (behaviorToken == nil) {
		QLog(@"+++ [ODD] Can't figure out owner from parent node '%@', container '%@'.", tokenMO.parentNode.kName, tokenMO.container.containerName);
	}

	return behaviorToken;
}

// Returns one of the following:
//
// - A class token.
// - A protocol token, perhaps because the member belongs to a category that we
//   have inferred is an informal protocol.
// - A category token.
// - nil if we can't figure out who should own the member token.
//
- (AKBehaviorToken *)_behaviorTokenFromInferredInfo:(AKInferredTokenInfo *)inferredInfo
{
	if (inferredInfo.nameOfProtocol) {
		return [self _getOrAddProtocolTokenWithName:inferredInfo.nameOfProtocol];
	}

	// If there's neither a protocol name nor a class name, we don't have enough to go on.
	if (inferredInfo.nameOfClass == nil) {
		return nil;
	}

	// If there's only a class name, return a class token.
	AKClassToken *classToken = [self _getOrAddClassTokenWithName:inferredInfo.nameOfClass];
	if (inferredInfo.nameOfCategory == nil) {
		return classToken;
	}

	// If the category name matches a known protocol name, return that protocol.
	//TODO: Handle the case where there isn't a protocol but there should be, e.g. because the name ends with "Delegate".
	AKProtocolToken *protocolToken = [self protocolTokenWithName:inferredInfo.nameOfCategory];
	if (protocolToken) {
		return protocolToken;
	}

	// The remaining case is that we have a "real" category.
	AKCategoryToken *categoryToken = [classToken categoryTokenWithName:inferredInfo.nameOfCategory];
	if (categoryToken == nil) {
		categoryToken = [[AKCategoryToken alloc] initWithName:inferredInfo.nameOfCategory];
		[classToken addCategoryToken:categoryToken];
	}
	return categoryToken;
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
		//QLog(@"+++ [ODD] Skipping protocol member token '%@', type '%@', container '%@'; it doesn't point to any documentation.", tokenMO.tokenName, tokenMO.tokenType.typeName, tokenMO.container.containerName);
		return nil;
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
	AKClassToken *classToken = self.classTokensByName[className];
	if (classToken == nil) {
		classToken = [[AKClassToken alloc] initWithName:className];
		self.classTokensByName[className] = classToken;
	}
	return classToken;
}

@end
