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
@property (readwrite, weak) AKClassToken *parentClass;
@property (copy) NSMutableDictionary *delegateMethodsByName;
@property (copy) NSMutableDictionary *bindingsByName;
@end


@implementation AKClassToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_namesOfAllOwningFrameworks = [[NSMutableArray alloc] init];

		_childClassTokens = [[NSMutableArray alloc] init];
		_categoryTokens = [[NSMutableArray alloc] init];

		_delegateMethodsByName = [[NSMutableDictionary alloc] init];
		_bindingsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark - Subclass tokens

- (void)addChildClass:(AKClassToken *)classToken
{
	// We check for parent != child to avoid circularity.  This
	// doesn't protect against the general case of a cycle, but it does
	// work around the typo in the Tiger docs where the superclass of
	// NSAnimation was given as NSAnimation.
	if (classToken == self) {
		DIGSLogDebug(@"ignoring attempt to make %@ a subclass of itself", self.name);
		return;
	}

	[classToken.parentClass removeChildClass:classToken];
	classToken.parentClass = self;
	[_childClassTokens addObject:classToken];
}

- (void)removeChildClass:(AKClassToken *)classToken
{
	NSInteger i = [_childClassTokens indexOfObject:classToken];
	if (i >= 0) {
		[classToken setParentClass:nil];
		[_childClassTokens removeObjectAtIndex:i];
	}
}

- (NSArray *)childClasses
{
	return _childClassTokens;
}

- (NSSet *)descendantClasses
{
	NSMutableSet *descendantClassTokens = [NSMutableSet setWithCapacity:50];
	[self _addDescendantsToSet:descendantClassTokens];
	return descendantClassTokens;
}

//- (BOOL)hasChildClasses
//{
//	return (_childClassTokens.count > 0);
//}

#pragma mark - Category tokens

- (AKCategoryToken *)categoryNamed:(NSString *)catName
{
	for (AKToken *item in _categoryTokens) {
		if ([item.name isEqualToString:catName]) {
			return (AKCategoryToken *)item;
		}
	}
	return nil;
}

- (void)addCategory:(AKCategoryToken *)categoryToken
{
	[categoryToken.owningClassToken removeCategoryToken:categoryToken];
	[_categoryTokens addObject:categoryToken];
	categoryToken.owningClassToken = self;
}

- (void)removeCategoryToken:(AKCategoryToken *)categoryToken
{
	NSInteger i = [_childClassTokens indexOfObject:categoryToken];
	if (i >= 0) {
		categoryToken.owningClassToken = nil;
		[_categoryTokens removeObjectAtIndex:i];
	}
}

- (NSArray *)allCategories
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:_categoryTokens];

	// Get categories from ancestor classes.
	if (self.parentClass) {
		[result addObjectsFromArray:self.parentClass.allCategories];
	}

	return result;
}

#pragma mark - Bindings tokens

- (void)addBindingToken:(AKBindingToken *)bindingToken
{
	self.bindingsByName[bindingToken.name] = bindingToken;
}

- (AKBindingToken *)bindingTokenNamed:(NSString *)bindingName
{
	return (AKBindingToken *)self.bindingsByName[bindingName];
}

- (NSArray *)bindingTokens
{
	return self.bindingsByName.allValues;
}

#pragma mark - Owning frameworks

- (void)setMainFrameworkName:(NSString *)frameworkName  //TODO: Fix the multiple-frameworks thing for class items.
{
	// Move this framework name to the beginning of _namesOfAllOwningFrameworks.
	if (frameworkName) {
		[_namesOfAllOwningFrameworks removeObject:frameworkName];
		[_namesOfAllOwningFrameworks insertObject:frameworkName atIndex:0];
	}
}

- (NSArray *)namesOfAllOwningFrameworks
{
	return _namesOfAllOwningFrameworks;
}

- (BOOL)isOwnedByFramework:(NSString *)frameworkName
{
	return [_namesOfAllOwningFrameworks containsObject:frameworkName];
}

//TODO: Commenting out, come back later.
//- (AKFileSection *)documentationAssociatedWithFramework:(NSString *)frameworkName
//{
//    return _tokenDocumentationByFrameworkName[frameworkName];
//}
//
//- (void)associateDocumentation:(AKFileSection *)fileSection
//            withFramework:(NSString *)frameworkName
//{
//    if (frameworkName == nil)
//    {
//        DIGSLogWarning(@"ODD -- nil framework name passed for %@ -- file %@",
//                       [self tokenName], [fileSection filePath]);
//        return;
//    }
//
//    if (![_namesOfAllOwningFrameworks containsObject:frameworkName])
//    {
//        [_namesOfAllOwningFrameworks addObject:frameworkName];
//    }
//
//    _tokenDocumentationByFrameworkName[frameworkName] = fileSection;
//}

#pragma mark - Delegate method tokens

- (NSArray *)delegateMethodTokens
{
	NSMutableArray *methodList = [self.delegateMethodsByName.allValues mutableCopy];

	// Handle classes like WebView that have different *kinds* of delegates.
	[self _addExtraDelegateMethodsTo:methodList];

	return methodList;
}

- (AKMethodToken *)delegateMethodWithName:(NSString *)methodName
{
	return (AKMethodToken *)self.delegateMethodsByName[methodName];
}

- (void)addDelegateMethod:(AKMethodToken *)methodToken
{
	self.delegateMethodsByName[methodToken.name] = methodToken;
	methodToken.owningBehavior = self;
}

#pragma mark - AKBehaviorToken methods

- (BOOL)isClassToken
{
	return YES;
}

- (NSArray *)implementedProtocols
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:[super implementedProtocols]];

	// Get protocols from ancestor classes.
	[result addObjectsFromArray:self.parentClass.implementedProtocols];

	return result;
}

#pragma mark - Private methods

- (void)_addDescendantsToSet:(NSMutableSet *)descendantClassTokens
{
	[descendantClassTokens addObject:self];
	for (AKClassToken *sub in _childClassTokens) {
		[sub _addDescendantsToSet:descendantClassTokens];
	}
}

// Look for a protocol named ThisClassDelegate.
// Look for instance method names of the form setFooDelegate:.
- (void)_addExtraDelegateMethodsTo:(NSMutableArray *)methodsList
{
//TODO: Commenting out for now, come back to this later.
//    // Look for a protocol named ThisClassDelegate.
//    AKDatabase *db = self.owningDatabase;
//    NSString *possibleDelegateProtocolName = [self.tokenName stringByAppendingString:@"Delegate"];
//    AKProtocolToken *delegateProtocol = [db protocolWithName:possibleDelegateProtocolName];
//
//    if (delegateProtocol)
//    {
//        [methodsList addObjectsFromArray:[delegateProtocol instanceMethodTokens]];
//    }
//
//    // Look for instance method names of the form setFooDelegate:.
//    //TODO: To be really thorough, check for fooDelegate properties.
//    for (AKMethodToken *methodToken in [self instanceMethodTokens])
//    {
//        NSString *methodName = methodToken.tokenName;
//
//        if ([methodName hasPrefix:@"set"]
//            && [methodName hasSuffix:@"Delegate:"]
//            && ![methodName isEqualToString:@"setDelegate:"])
//        {
//            //TODO: Can't I just look for protocol FooDelegate?
//            NSString *protocolSuffix = [[methodName substringToIndex:(methodName.length - 1)]
//                                         substringFromIndex:3].uppercaseString;
//
//            for (AKProtocolToken *protocolToken in [db allProtocols])
//            {
//                NSString *protocolName = protocolToken.tokenName.uppercaseString;
//
//                if ([protocolName hasSuffix:protocolSuffix])
//                {
//                    [methodsList addObjectsFromArray:[protocolToken instanceMethodTokens]];
//                    
//                    break;
//                }
//            }
//        }
//    }
}

@end
