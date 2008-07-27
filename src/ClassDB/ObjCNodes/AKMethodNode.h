//
// AKMethodNode.h
//
// Created by Andy Lee on Thu Jun 27 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKMemberNode.h"

// nodeName is method name.

/*!
 * @class       AKMethodNode
 * @abstract    Represents an Objective-C method.
 * @discussion  An AKMethodNode contains the name and signature of
 *              an Objective-C method.  The method may be either a class
 *              method or an instance method; AKMethodNode does not
 *              distinguish between the two.
 *
 *              An AKMethodNode instance can only belong to one
 *              AKBehaviorNode, regardless of how many behaviors
 *              declare a method with the same signature.
 *
 *              An AKMethodNode's -nodeName is the name of the method
 *              it represents -- i.e., a string that could be passed to
 *              NSSelectorFromString().
 */
@interface AKMethodNode : AKMemberNode
{
@private
    NSMutableArray *_argumentTypes;
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSArray *)argumentTypes;
- (void)setArgumentTypes:(NSArray *)argTypes;

@end
