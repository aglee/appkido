//
// AKBehaviorNode.h
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKDatabaseNode.h"

@class AKBehaviorNode;
@class AKCollectionOfNodes;
@class AKMemberNode;
@class AKMethodNode;
@class AKPropertyNode;
@class AKProtocolNode;

typedef id (^AKBlockForGettingMemberNode)(AKBehaviorNode *behaviorNode, NSString *memberName);

typedef void (^AKBlockForAddingMemberNode)(AKBehaviorNode *behaviorNode, AKMemberNode *memberNode);

#define blockForGettingMemberNode(xxxWithName) ^id (AKBehaviorNode *behaviorNode, NSString *memberName) { return [(id)behaviorNode xxxWithName:memberName]; }

#define blockForAddingMemberNode(addXXXNode) ^void (AKBehaviorNode *behaviorNode, AKMemberNode *memberNode) { [(id)behaviorNode addXXXNode:(id)memberNode]; }

/*!
 * Abstract class. Represents an Objective-C construct that can have methods.
 * The concrete subclasses are AKClassNode, AKProtocolNode, and AKCategoryNode.
 */
@interface AKBehaviorNode : AKDatabaseNode

/*! Path to the .h file that declares this behavior. */
@property (nonatomic, copy) NSString *headerFileWhereDeclared;


#pragma mark -
#pragma mark Getters and setters -- general

// [agl] Old note to self says that classes can have multiple header paths. Example?

/*!
 * Names of all frameworks the behavior belongs to.  The first element of the
 * returned array is the name of its primary framework (its owningFramework --
 * which should be the framework that declares the behavior). After that, the
 * order of the array is the order in which it was discovered that the behavior
 * belongs to the framework.
 */
- (NSArray *)namesOfAllOwningFrameworks;

- (BOOL)isClassNode;

- (void)addImplementedProtocol:(AKProtocolNode *)node;

/*!
 * Returns zero or more AKProtocolNodes, one for each protocol implemented by
 * the represented behavior. Includes protocols implemented by virtue of
 * inheritance.
 */
- (NSArray *)implementedProtocols;

/*! Returns zero or more AKMethodNodes. */
- (NSArray *)instanceMethodNodes;

/*! frameworkName can be the main framework or an extra one. */
- (AKFileSection *)nodeDocumentationForFrameworkNamed:(NSString *)frameworkName;

- (void)setNodeDocumentation:(AKFileSection *)fileSection
           forFrameworkNamed:(NSString *)frameworkName;


#pragma mark -
#pragma mark Getters and setters -- properties

/*! Returns only properties that are in this class's documentation. */
- (NSArray *)documentedProperties;

- (AKPropertyNode *)propertyNodeWithName:(NSString *)propertyName;

/*! Does nothing if a property with the same name already exists. */
- (void)addPropertyNode:(AKPropertyNode *)propertyNode;


#pragma mark -
#pragma mark Getters and setters -- class methods

/*!
 * Returns AKMethodNodes for class methods that have documentation
 * associated with them.  Does not include inherited methods.
 */
- (NSArray *)documentedClassMethods;

- (AKMethodNode *)classMethodWithName:(NSString *)methodName;

/*! Does nothing if a class method with the same name already exists. */
- (void)addClassMethod:(AKMethodNode *)methodNode;


#pragma mark -
#pragma mark Getters and setters -- instance methods

/*!
 * Returns AKMethodNodes for instance methods that have documentation
 * associated with them.  Does not include inherited methods.
 */
- (NSArray *)documentedInstanceMethods;

- (AKMethodNode *)instanceMethodWithName:(NSString *)methodName;

/*! Does nothing if an instance method with the same name already exists. */
- (void)addInstanceMethod:(AKMethodNode *)methodNode;


#pragma mark -
#pragma mark Getters and setters -- deprecated methods

/*!
 * We have to guess whether it's a class method or instance method,
 * because the docs lump all deprecated methods together.
 */
- (AKMethodNode *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
                                      owningFramework:(AKFramework *)nodeOwningFW;


@end
