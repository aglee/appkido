//
// AKMethodNode.h
//
// Created by Andy Lee on Thu Jun 27 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKMemberNode.h"

/*!
 * Represents an Objective-C method. Contains the name and signature of the
 * method. Does not distinguish between class and instance methods.
 *
 * An AKMethodNode instance must belong to at most one AKBehaviorNode instance,
 * regardless of how many behaviors declare a method with the same signature.
 */
@interface AKMethodNode : AKMemberNode


#pragma mark -
#pragma mark Getters and setters

- (BOOL)isClassMethod;

- (BOOL)isDelegateMethod;

- (NSArray *)argumentTypes;
- (void)setArgumentTypes:(NSArray *)argTypes;

@end
