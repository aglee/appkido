//
// AKMethodItem.h
//
// Created by Andy Lee on Thu Jun 27 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKMemberItem.h"

/*!
 * Represents an Objective-C method. Contains the name and signature of the
 * method. Does not distinguish between class and instance methods.
 *
 * An AKMethodItem instance must belong to at most one AKBehaviorItem instance,
 * regardless of how many behaviors declare a method with the same signature.
 */
@interface AKMethodItem : AKMemberItem
{
@private
    NSMutableArray *_argumentTypes;
}

#pragma mark -
#pragma mark Getters and setters

@property (NS_NONATOMIC_IOSONLY, getter=isClassMethod, readonly) BOOL classMethod;

@property (NS_NONATOMIC_IOSONLY, getter=isDelegateMethod, readonly) BOOL delegateMethod;

@property (NS_NONATOMIC_IOSONLY, copy) NSArray *argumentTypes;

@end
