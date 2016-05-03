//
// AKBehaviorItem.h
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKTokenItem.h"

@class AKBehaviorItem;
@class AKCollectionOfItems;
@class AKMemberItem;
@class AKMethodItem;
@class AKPropertyItem;
@class AKProtocolItem;

#pragma mark - Blocks as alternatives to performSelector

typedef id (^AKBlockForGettingMemberItem)(AKBehaviorItem *behaviorItem, NSString *memberName);

typedef void (^AKBlockForAddingMemberItem)(AKBehaviorItem *behaviorItem, AKMemberItem *memberItem);

#define blockForGettingMemberItem(xxxWithName) ^id (AKBehaviorItem *behaviorItem, NSString *memberName) { return [(id)behaviorItem xxxWithName:memberName]; }

#define blockForAddingMemberItem(addXXXItem) ^void (AKBehaviorItem *behaviorItem, AKMemberItem *memberItem) { [(id)behaviorItem addXXXItem:(id)memberItem]; }


#pragma mark -

/*!
 * Abstract class. Represents an Objective-C construct that can have methods.
 * The concrete subclasses are AKClassItem, AKProtocolItem, and AKCategoryItem.
 *
 * Note: unlike other database items, class and protocol items can be
 * initialized with nil as their owning framework name. The reason is that when
 * we are constructing the database, we may encounter a reference to a class or
 * protocol before it has been declared. For example, we may encounter a
 * category (and thus the name of its owning class) before we encounter the
 * owning class's declaration. Or we may encounter a protocol in a class's list
 * of protocols before we've encountered its @protocol declaration.
 */
@interface AKBehaviorItem : AKTokenItem
{
@private
	// One AKProtocolItem for each protocol this behavior conforms to.
	NSMutableArray *_protocolItems;

	// Indexes the contents of _protocolItems.
	NSMutableSet *_protocolItemNames;

	// Contains AKPropertyItems, each representing a property of this class.
	AKCollectionOfItems *_indexOfProperties;

	// Contains AKMethodItems, one for each class method that has either
	// been found in my .h file or been found in the documentation for my
	// behavior.
	AKCollectionOfItems *_indexOfClassMethods;

	// Contains AKMethodItems, one for each instance method that has either
	// been found in my .h file or been found in the documentation for my
	// behavior.
	AKCollectionOfItems *_indexOfInstanceMethods;
}

#pragma mark - Getters and setters -- general

@property (NS_NONATOMIC_IOSONLY, assign, readonly) BOOL isClassItem;
/*! Includes protocols implemented by virtue of inheritance. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *implementedProtocols;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *instanceMethodItems;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *propertyItems;

#pragma mark - Getters and setters -- properties

- (void)addImplementedProtocol:(AKProtocolItem *)protocolItem;
- (void)addImplementedProtocols:(NSArray *)protocolItems;

- (AKPropertyItem *)propertyItemWithName:(NSString *)propertyName;
/*! Does nothing if a property with the same name already exists. */
- (void)addPropertyItem:(AKPropertyItem *)propertyItem;

#pragma mark - Getters and setters -- class methods

/*! Does not include inherited methods. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *documentedClassMethods;
- (AKMethodItem *)classMethodWithName:(NSString *)methodName;
/*! Does nothing if a class method with the same name already exists. */
- (void)addClassMethod:(AKMethodItem *)methodItem;

#pragma mark - Getters and setters -- instance methods

- (AKMethodItem *)instanceMethodWithName:(NSString *)methodName;
/*! Does nothing if an instance method with the same name already exists. */
- (void)addInstanceMethod:(AKMethodItem *)methodItem;

#pragma mark - Getters and setters -- deprecated methods

/*!
 * We have to guess whether it's a class method or instance method,
 * because the docs lump all deprecated methods together.
 */
- (AKMethodItem *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
										frameworkName:(NSString *)frameworkName;

@end
