/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDoc.h"

@class AKBehaviorItem;
@class AKMemberItem;

@interface AKMemberDoc : AKDoc
{
@private
    AKMemberItem *_memberItem;
    AKBehaviorItem *_behaviorItem;
}

@property (nonatomic, readonly, strong) AKMemberItem *memberItem;
@property (nonatomic, readonly, strong) AKBehaviorItem *behaviorItem;

#pragma mark -
#pragma mark Init/awake/dealloc

// Designated initializer
- (instancetype)initWithMemberItem:(AKMemberItem *)memberItem
     inheritedByBehavior:(AKBehaviorItem *)behaviorItem NS_DESIGNATED_INITIALIZER;

#pragma mark -
#pragma mark Manipulating node names

/*! Subclasses must override this. */
+ (NSString *)punctuateTokenName:(NSString *)memberName;

#pragma mark -
#pragma mark AKDoc methods

/*!
 * This implementation of -commentString assumes the receiver represents a
 * method.  Subclasses of AKMemberDoc for which this is not true need to
 * override this method.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *commentString;

@end
