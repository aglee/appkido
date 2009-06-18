/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDoc.h"

@class AKBehaviorNode;
@class AKMemberNode;

@interface AKMemberDoc : AKDoc
{
    AKMemberNode *_memberNode;
    AKBehaviorNode *_behaviorNode;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithMemberNode:(AKMemberNode *)memberNode
    inheritedByBehavior:(AKBehaviorNode *)behaviorNode;

//-------------------------------------------------------------------------
// Manipulating node names
//-------------------------------------------------------------------------

/*! Must override this. */
+ (NSString *)punctuateNodeName:(NSString *)memberName;

//-------------------------------------------------------------------------
// AKDoc methods
//-------------------------------------------------------------------------

/*!
 * This implementation of -commentString assumes the receiver represents a
 * method.  Subclasses of AKMemberDoc for which this is not true need to
 * override this method.
 */
- (NSString *)commentString;

@end
