/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase.h"
#import "AKBindingItem.h"
#import "AKCategoryItem.h"
#import "AKFrameworkConstants.h"
#import "AKDevToolsUtils.h"
#import "AKPrefUtils.h"
#import "AKClassItem.h"
#import "AKMethodItem.h"
#import "AKPropertyItem.h"
#import "AKProtocolItem.h"
#import "AKGroupItem.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"
#import "AKRegexUtils.h"
#import "DIGSLog.h"
#import "DocSetQuery.h"
#import "QuietLog.h"


@interface AKDatabase ()
@property (NS_NONATOMIC_IOSONLY, readwrite, copy) NSArray *frameworkNames;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSMutableDictionary *classItemsByName;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSMutableDictionary *protocolItemsByName;
@end


@implementation AKDatabase

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex
{
	self = [super init];
	if (self) {
		_docSetIndex = docSetIndex;
		_frameworkNames = @[];
		_classItemsByName = [[NSMutableDictionary alloc] init];
		_protocolItemsByName = [[NSMutableDictionary alloc] init];
		_functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
		_functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

		_globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
		_globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

		_classItemsByHTMLPath = [[NSMutableDictionary alloc] init];
		_protocolItemsByHTMLPath = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithDocSetIndex:nil];
}

#pragma mark - Populating the database

- (void)populate
{
	self.frameworkNames = [self _sortedArrayWithAllFrameworkNames];

	[self _importAllTokens];

}

#pragma mark - Getters and setters -- frameworks

- (NSArray *)sortedFrameworkNames
{
	return self.frameworkNames;
}

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName
{
	return [self.frameworkNames containsObject:frameworkName];
}

#pragma mark - Getters and setters -- classes

- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName
{
	NSMutableArray *classItems = [NSMutableArray array];
	for (AKClassItem *classItem in [self allClasses]) {
		if ([classItem.frameworkName isEqualToString:frameworkName]) 	{
			[classItems addObject:classItem];
		}
	}
	return classItems;
}

- (NSArray *)rootClasses
{
	NSMutableArray *result = [NSMutableArray array];
	for (AKClassItem *classItem in [self allClasses]) {
		if (classItem.parentClass == nil) {
			[result addObject:classItem];
		}
	}
	return result;
}

- (NSArray *)allClasses
{
	return self.classItemsByName.allValues;
}

- (AKClassItem *)classWithName:(NSString *)className
{
	return self.classItemsByName[className];
}

#pragma mark - Getters and setters -- protocols

- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
	return [self _allProtocolsForFrameworkNamed:frameworkName withInformalFlag:NO];
}

- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
	return [self _allProtocolsForFrameworkNamed:frameworkName withInformalFlag:YES];
}

- (NSArray *)allProtocols
{
	return _protocolItemsByName.allValues;
}

- (AKProtocolItem *)protocolWithName:(NSString *)name
{
	return _protocolItemsByName[name];
}

- (void)addProtocolItem:(AKProtocolItem *)protocolItem
{
	// Do nothing if we already have a protocol with the same name.
	NSString *protocolName = protocolItem.tokenName;
	if (_protocolItemsByName[protocolName]) {
		DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
		return;
	}

	// Add the protocol to our lookup by protocol name.
	_protocolItemsByName[protocolName] = protocolItem;
}

#pragma mark - Getters and setters -- functions

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
	return _functionsGroupListsByFramework[frameworkName];
}

- (AKGroupItem *)functionsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName
{
	return _functionsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addFunctionsGroup:(AKGroupItem *)groupItem
{
	NSString *frameworkName = groupItem.frameworkName;

	// See if we have any functions groups in the framework yet.
	NSMutableArray *groupList = nil;
	NSMutableDictionary *groupsByName = _functionsGroupsByFrameworkAndGroup[frameworkName];

	if (groupsByName) {
		groupList = _functionsGroupListsByFramework[frameworkName];
	} else {
		groupsByName = [NSMutableDictionary dictionary];
		_functionsGroupsByFrameworkAndGroup[frameworkName] = groupsByName;

		groupList = [NSMutableArray array];
		_functionsGroupListsByFramework[frameworkName] = groupList;
	}

	// Add the functions group if it isn't already in the framework.
	NSString *groupName = groupItem.tokenName;

	if (groupsByName[groupName]) {
		DIGSLogWarning(@"Trying to add functions group [%@] again", groupName);
	} else {
		[groupList addObject:groupItem];
		groupsByName[groupItem.tokenName] = groupItem;
	}
}

#pragma mark - Getters and setters -- globals

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
	return _globalsGroupListsByFramework[frameworkName];
}

- (AKGroupItem *)globalsGroupNamed:(NSString *)groupName
				  inFrameworkNamed:(NSString *)frameworkName
{
	return _globalsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addGlobalsGroup:(AKGroupItem *)groupItem
{
	NSString *frameworkName = groupItem.frameworkName;

	// See if we have any globals groups in the framework yet.
	NSMutableArray *groupList = nil;
	NSMutableDictionary *groupsByName = _globalsGroupsByFrameworkAndGroup[frameworkName];

	if (groupsByName) {
		groupList = _globalsGroupListsByFramework[frameworkName];
	} else {
		groupsByName = [NSMutableDictionary dictionary];
		_globalsGroupsByFrameworkAndGroup[frameworkName] = groupsByName;

		groupList = [NSMutableArray array];
		_globalsGroupListsByFramework[frameworkName] = groupList;
	}

	// Add the globals group if it isn't already in the framework.
	NSString *groupName = groupItem.tokenName;

	if (groupsByName[groupName]) {
		DIGSLogWarning(@"Trying to add globals group [%@] again", groupName);
	} else {
		[groupList addObject:groupItem];
		groupsByName[groupItem.tokenName] = groupItem;
	}
}

#pragma mark - Private methods - misc

- (NSArray *)_allProtocolsForFrameworkNamed:(NSString *)fwName
						   withInformalFlag:(BOOL)informalFlag
{
	NSMutableArray *result = [NSMutableArray array];
	for (AKProtocolItem *protocolItem in [self allProtocols]) {
		if ((protocolItem.isInformal == informalFlag)
			&& [protocolItem.frameworkName isEqualToString:fwName]) {

			[result addObject:protocolItem];
		}
	}
	return result;
}

#pragma mark - Private methods - populating the database - misc

- (void)_importAllTokens
{
	for (DSAToken *token in [self _arrayWithAllTokens]) {
		NSString *tokenType = token.tokenType.typeName;

		if ([tokenType isEqualToString:@"cl"] || [tokenType isEqualToString:@"cat"]) {

			// Class or category.
			AKBehaviorItem *item = [self _getOrAddClassOrCategoryItemWithName:token.tokenName];
			if ([item isKindOfClass:[AKClassItem class]]) {
				AKClassItem *classItem = (AKClassItem *)item;
				classItem.token = token;
				if (classItem.parentClass == nil) {
					[self _fillInParentClassOfClassItem:classItem];
				}
			}

		} else if ([tokenType isEqualToString:@"clm"]) {

			// Class method of either a class or a category.
			[self _importClassMethodToken:token];

		} else if ([tokenType isEqualToString:@"instm"]) {

			// Instance method of either a class or a category.
			[self _importInstanceMethodToken:token];

		} else if ([tokenType isEqualToString:@"instp"]) {

			// Property of either a class or a category.
			[self _importPropertyToken:token];

		} else if ([tokenType isEqualToString:@"binding"]) {

			// Binding exposed by a class.
			[self _importBindingToken:token];

		} else if ([tokenType isEqualToString:@"intf"]) {

			// Protocol.
			[self _importProtocolToken:token];

		} else if ([tokenType isEqualToString:@"intfcm"]) {

			// Class method of a protocol.
			[self _importProtocolClassMethodToken:token];

		} else if ([tokenType isEqualToString:@"intfm"]) {

			// Instance method of a protocol.
			[self _importProtocolInstanceMethodToken:token];

		} else if ([tokenType isEqualToString:@"intfp"]) {

			// Property of a protocol.
			[self _importProtocolPropertyToken:token];

		} else {
			
			QLog(@"+++ %s [ODD] Unexpected token type '%@'", __PRETTY_FUNCTION__, tokenType);
			
		}
	}
}

- (NSArray *)_sortedArrayWithAllFrameworkNames
{
	NSError *error;
	DocSetQuery *query = [self.docSetIndex queryWithEntityName:@"Header"];
	query.distinctKeyPathsString = @"frameworkName";
	query.predicateString = @"frameworkName != NULL";
	NSArray *fetchedObjects = [query fetchObjectsWithError:&error];  //TODO: Handle error.
	NSArray *frameworkNames = [fetchedObjects valueForKey:@"frameworkName"];
	frameworkNames = [frameworkNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	return frameworkNames;
}

- (NSArray *)_arrayWithAllTokens
{
	NSError *error;
	DocSetQuery *query = [self.docSetIndex queryWithEntityName:@"Token"];
	query.predicateString = @"language.fullName = 'Objective-C'";
	return [query fetchObjectsWithError:&error];  //TODO: Handle error.
}

#pragma mark - Private methods - populating the database - classes and categories

// The contorted logic here is a workaround for what looks like a bug in the
// 10.11.4 docset.  It contains tokens that are marked as classes (token type
// "cl"), where that is clearly an error, because their names have the form of
// category names, e.g. "NSObject(NSFontPanelValidationAdditions)".  So rather
// than trust the token type, this method goes by the token name to decide what
// kind of token it is.
- (AKBehaviorItem *)_getOrAddClassOrCategoryItemWithName:(NSString *)name
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
//		QLog(@"+++ added category %@ to class %@", categoryName, className);
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
//		QLog(@"+++ class '%@', no token yet", classItem.tokenName);
	}
	return classItem;
}

- (void)_fillInParentClassOfClassItem:(AKClassItem *)classItem
{
	if (classItem.token.superclassContainers.count > 1) {
		QLog(@"%s [ODD] Unexpected multiple inheritance for class %@", __PRETTY_FUNCTION__, classItem.tokenName);
	}
	Container *container = classItem.token.superclassContainers.anyObject;
	if (container) {
		AKClassItem *parentClassItem = [self _getOrAddClassItemWithName:container.containerName];
		[parentClassItem addChildClass:classItem];
//		QLog(@"+++ parent class '%@' => child class '%@'", parentClassItem.tokenName, classItem.tokenName);
	}
}

- (void)_importClassMethodToken:(DSAToken *)token
{
	NSParameterAssert([token.tokenType.typeName isEqualToString:@"clm"]);
	NSString *containerName = token.container.containerName;
	AKBehaviorItem *behaviorItem = [self _getOrAddClassOrCategoryItemWithName:containerName];
	AKMethodItem *methodItem = [[AKMethodItem alloc] initWithToken:token owningBehavior:behaviorItem];
	[behaviorItem addClassMethod:methodItem];
}

- (void)_importInstanceMethodToken:(DSAToken *)token
{
	NSParameterAssert([token.tokenType.typeName isEqualToString:@"instm"]);
	NSString *containerName = token.container.containerName;
	AKBehaviorItem *behaviorItem = [self _getOrAddClassOrCategoryItemWithName:containerName];
	AKMethodItem *methodItem = [[AKMethodItem alloc] initWithToken:token owningBehavior:behaviorItem];
	[behaviorItem addInstanceMethod:methodItem];
//	QLog(@"+++ added instance method %@ to %@ %@", methodItem.tokenName, [behaviorItem className], containerName);
}

- (void)_importPropertyToken:(DSAToken *)token
{
	NSParameterAssert([token.tokenType.typeName isEqualToString:@"instp"]);
	NSString *containerName = token.container.containerName;
	AKBehaviorItem *behaviorItem = [self _getOrAddClassOrCategoryItemWithName:containerName];
	AKPropertyItem *propertyItem = [[AKPropertyItem alloc] initWithToken:token owningBehavior:behaviorItem];
	[behaviorItem addPropertyItem:propertyItem];
}

- (void)_importBindingToken:(DSAToken *)token
{
	NSParameterAssert([token.tokenType.typeName isEqualToString:@"binding"]);
	NSString *className = token.container.containerName;
	AKClassItem *classItem = (AKClassItem *)[self _getOrAddClassOrCategoryItemWithName:className];
	AKBindingItem *bindingItem = [[AKBindingItem alloc] initWithToken:token owningBehavior:classItem];
	[classItem addBindingItem:bindingItem];
//	QLog(@"+++ added binding '%@' to class '%@'", bindingItem.tokenName, classItem.tokenName);
}

#pragma mark - Private methods - populating the database - protocols

- (void)_importProtocolToken:(DSAToken *)token
{
	NSParameterAssert([token.tokenType.typeName isEqualToString:@"intf"]);
	(void)[self _getOrAddProtocolItemWithToken:token];
}

- (AKProtocolItem *)_getOrAddProtocolItemWithToken:(DSAToken *)token
{
	AKProtocolItem *protocolItem = [self _getOrAddProtocolItemWithName:token.tokenName];
	if (protocolItem.token == nil) {
		protocolItem.token = token;
//		QLog(@"+++ protocol '%@' has token, is in framework '%@'", protocolItem.tokenName, protocolItem.frameworkName);
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
//		QLog(@"+++ protocol '%@', no token yet", protocolItem.tokenName);
	}
	return protocolItem;
}

- (void)_importProtocolClassMethodToken:(DSAToken *)token
{
	NSParameterAssert([token.tokenType.typeName isEqualToString:@"intfcm"]);
	NSString *protocolName = token.container.containerName;
	AKProtocolItem *protocolItem = [self _getOrAddProtocolItemWithName:protocolName];
	AKMethodItem *methodItem = [[AKMethodItem alloc] initWithToken:token owningBehavior:protocolItem];
	[protocolItem addClassMethod:methodItem];
}

- (void)_importProtocolInstanceMethodToken:(DSAToken *)token
{
	NSParameterAssert([token.tokenType.typeName isEqualToString:@"intfm"]);
	NSString *protocolName = token.container.containerName;
	AKProtocolItem *protocolItem = [self _getOrAddProtocolItemWithName:protocolName];
	AKMethodItem *methodItem = [[AKMethodItem alloc] initWithToken:token owningBehavior:protocolItem];
	[protocolItem addInstanceMethod:methodItem];
}

- (void)_importProtocolPropertyToken:(DSAToken *)token
{
	NSParameterAssert([token.tokenType.typeName isEqualToString:@"intfp"]);
	NSString *propertyName = token.container.containerName;
	AKProtocolItem *protocolItem = [self _getOrAddProtocolItemWithName:propertyName];
	AKPropertyItem *propertyItem = [[AKPropertyItem alloc] initWithToken:token owningBehavior:protocolItem];
	[protocolItem addPropertyItem:propertyItem];
}

@end
