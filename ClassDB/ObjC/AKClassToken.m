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
#import "AKCollectionOfItems.h"
#import "AKDatabase.h"
#import "AKMethodToken.h"
#import "AKNotificationToken.h"
#import "AKProtocolToken.h"
#import "NSString+AppKiDo.h"


@interface AKClassToken ()
@property (NS_NONATOMIC_IOSONLY, readwrite, weak) AKClassToken *parentClass;
@end


@implementation AKClassToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
	self = [super initWithTokenMO:tokenMO];
	if (self) {
		_namesOfAllOwningFrameworks = [[NSMutableArray alloc] init];
		_tokenDocumentationByFrameworkName = [[NSMutableDictionary alloc] init];

		_childClassTokens = [[NSMutableArray alloc] init];
		_categoryTokens = [[NSMutableArray alloc] init];

		_indexOfDelegateMethods = [[AKCollectionOfItems alloc] init];
		_indexOfNotifications = [[AKCollectionOfItems alloc] init];
		_indexOfBindings = [[AKCollectionOfItems alloc] init];
	}
	return self;
}

- (void)dealloc
{
	_indexOfDelegateMethods = nil;
}

#pragma mark - Getters and setters -- general

- (void)addChildClass:(AKClassToken *)classToken
{
	// We check for parent != child to avoid circularity.  This
	// doesn't protect against the general case of a cycle, but it does
	// work around the typo in the Tiger docs where the superclass of
	// NSAnimation was given as NSAnimation.
	if (classToken == self) {
		DIGSLogDebug(@"ignoring attempt to make %@ a subclass of itself", [self tokenName]);
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

- (BOOL)hasChildClasses
{
	return (_childClassTokens.count > 0);
}

- (AKCategoryToken *)categoryNamed:(NSString *)catName
{
	for (AKToken *item in _categoryTokens) {
		if ([item.tokenName isEqualToString:catName]) {
			return (AKCategoryToken *)item;
		}
	}
	return nil;
}

- (void)addCategory:(AKCategoryToken *)categoryToken
{
	[_categoryTokens addObject:categoryToken];
}

- (NSArray *)allCategories
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:_categoryTokens];

	// Get categories from ancestor classes.
	if (_parentClass) {
		[result addObjectsFromArray:[_parentClass allCategories]];
	}

	return result;
}

- (void)addBindingToken:(AKBindingToken *)bindingToken
{
	[_indexOfBindings addToken:bindingToken];
}

- (AKBindingToken *)bindingTokenNamed:(NSString *)bindingName
{
	return (AKBindingToken *)[_indexOfBindings itemWithTokenName:bindingName];
}

- (NSArray *)documentedBindings
{
	return [_indexOfBindings allItems];
}

#pragma mark - Getters and setters -- multiple owning frameworks

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

#pragma mark - Getters and setters -- delegate methods

- (NSArray *)documentedDelegateMethods
{
	NSMutableArray *methodList = [[_indexOfDelegateMethods allItems] mutableCopy];

	// Handle classes like WebView that have different *kinds* of delegates.
	[self _addExtraDelegateMethodsTo:methodList];

	return methodList;
}

- (AKMethodToken *)delegateMethodWithName:(NSString *)methodName
{
	return (AKMethodToken *)[_indexOfDelegateMethods itemWithTokenName:methodName];
}

- (void)addDelegateMethod:(AKMethodToken *)methodToken
{
	[_indexOfDelegateMethods addToken:methodToken];
}

#pragma mark - Getters and setters -- notifications

- (NSArray *)documentedNotifications
{
	return [_indexOfNotifications allItems];
}

- (AKNotificationToken *)notificationWithName:(NSString *)notificationName
{
	return (AKNotificationToken *)[_indexOfNotifications itemWithTokenName:notificationName];
}

- (void)addNotification:(AKNotificationToken *)notificationToken
{
	[_indexOfNotifications addToken:notificationToken];
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
	[result addObjectsFromArray:[_parentClass implementedProtocols]];

	return result;
}

- (AKMethodToken *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
										frameworkName:(NSString *)frameworkName
{
	AKMethodToken *methodToken = [super addDeprecatedMethodIfAbsentWithName:methodName
															frameworkName:frameworkName];

//FIXME:
//    // If it's neither an instance method nor a class method, but it looks
//    // like it might be a delegate method, assume it is one.
//    //TODO: Old note to self says this assumption is false for [NSTypesetter lineFragmentRectForProposedRect:remainingRect:].  Check on this.
//    if (methodToken == nil)
//    {
//        if ([methodName ak_contains:@":"])
//        {
//            methodToken = [[AKMethodToken alloc] initWithTokenName:methodName
//                                                        database:self.owningDatabase
//                                                   frameworkName:frameworkName
//                                                  owningBehavior:self];
//            [methodToken setIsDeprecated:YES];
//            [self addDelegateMethod:methodToken];
//        }
//        else
//        {
//            DIGSLogInfo(@"Skipping method named %@ because it doesn't look like a delegate method"
//                        @" while processing deprecated methods in behavior %@",
//                        methodName, [self tokenName]);
//        }
//    }

	return methodToken;
}

#pragma mark - AKToken methods

- (NSString *)tokenName
{
	return super.tokenName ?: self.fallbackTokenName;
}

- (void)setMainFrameworkName:(NSString *)frameworkName  //TODO: Fix the multiple-frameworks thing for class items.
{
	// Move this framework name to the beginning of _namesOfAllOwningFrameworks.
	if (frameworkName) {
		[_namesOfAllOwningFrameworks removeObject:frameworkName];
		[_namesOfAllOwningFrameworks insertObject:frameworkName atIndex:0];
	}
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
