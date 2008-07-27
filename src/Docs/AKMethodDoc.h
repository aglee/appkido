/*
 * AKMethodDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDoc.h"

@class AKBehaviorNode;
@class AKMethodNode;

@interface AKMethodDoc : AKDoc
{
    AKMethodNode *_methodNode;
    AKBehaviorNode *_behaviorNode;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithMethodNode:(AKMethodNode *)methodNode
    inheritedByBehavior:(AKBehaviorNode *)behaviorNode;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (AKMethodNode *)docMethodNode;

//-------------------------------------------------------------------------
// Manipulating method names
//-------------------------------------------------------------------------

// Override this.
+ (NSString *)punctuateMethodName:(NSString *)methodName;

@end
