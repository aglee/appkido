/*
 * AKGlobalsNode.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabaseNode.h"

/*!
 * @class       AKGlobalsNode
 * @abstract    Represents a collection of global Objective-C identifiers.
 * @discussion  An AKGlobalsNode represents a collection of
 *              global identifiers such as enums, constant names, global
 *              variable names, and typedefs.
 *
 *              An AKGlobalsNode's -nodeName depends on the type
 *              of global it contains.  For example, the node name might
 *              be the name of a typedef'ed enumeration, and the names
 *              it contains might be the names of the enums.
 */
@interface AKGlobalsNode : AKDatabaseNode
{
@private
    // Elements are strings.
    NSMutableArray *_namesOfGlobals;
}


#pragma mark -
#pragma mark Getters and setters

- (void)addNameOfGlobal:(NSString *)nameOfGlobal;

- (NSArray *)namesOfGlobals;

@end
