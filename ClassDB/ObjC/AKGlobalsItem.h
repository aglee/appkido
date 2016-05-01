/*
 * AKGlobalsItem.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTokenItem.h"

/*!
 * Represents a collection of global identifiers such as enums, constant names,
 * global variable names, and typedefs. For example, the item name might be the
 * name of a typedef'ed enumeration, and the names it contains might be the
 * names of the enums. The owned identifiers are not themselves database items;
 * they're just strings.
 */
@interface AKGlobalsItem : AKTokenItem
{
@private
    // Elements are strings.
    NSMutableArray *_namesOfGlobals;
}

#pragma mark - Getters and setters

- (void)addNameOfGlobal:(NSString *)nameOfGlobal;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *namesOfGlobals;

@end
