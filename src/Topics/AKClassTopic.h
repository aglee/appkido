/*
 * AKClassTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

@class AKClassNode;

@interface AKClassTopic : AKBehaviorTopic
{
@private
    AKClassNode *_classNode;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)topicWithClassNode:(AKClassNode *)classNode
    inDatabase:(AKDatabase *)database;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithClassNode:(AKClassNode *)classNode
    inDatabase:(AKDatabase *)database;

@end
