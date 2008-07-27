//
// AKCategoryNode.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorNode.h"

// nodeName is category name

/*!
 * @class       AKCategoryNode
 * @abstract    Represents an Objective-C category.
 * @discussion  An AKCategoryNode represents a category used to extend a
 *              class.
 *
 *              An AKCategoryNode's -nodeName is the name of the category
 *              it represents (not including the name of the class the
 *              category extends).
 *
 *              [agl] This class currently isn't complete and isn't used
 *              for anything serious.
 */
@interface AKCategoryNode : AKBehaviorNode
{
}

@end
