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
@private
    AKMemberNode *_memberNode;
    AKBehaviorNode *_behaviorNode;
}

@property (nonatomic, readonly, strong) AKMemberNode *memberNode;
@property (nonatomic, readonly, strong) AKBehaviorNode *behaviorNode;

#pragma mark -
#pragma mark Init/awake/dealloc

// Designated initializer
- (instancetype)initWithMemberNode:(AKMemberNode *)memberNode
     inheritedByBehavior:(AKBehaviorNode *)behaviorNode NS_DESIGNATED_INITIALIZER;

#pragma mark -
#pragma mark Manipulating node names

/*! Subclasses must override this. */
+ (NSString *)punctuateNodeName:(NSString *)memberName;

#pragma mark -
#pragma mark AKDoc methods

/*!
 * This implementation of -commentString assumes the receiver represents a
 * method.  Subclasses of AKMemberDoc for which this is not true need to
 * override this method.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *commentString;

@end
