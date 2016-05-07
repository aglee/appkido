/*
 * AKMembersSubtopic.h
 *
 * Created by Andy Lee on Tue Jul 09 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

@class AKBehaviorItem;

@interface AKMembersSubtopic : AKSubtopic
{
@private
    // Do we include methods inherited from ancestor classes and declared
    // in protocols?
    BOOL _includesAncestors;
}

#pragma mark - Init/awake/dealloc

- (instancetype)initIncludingAncestors:(BOOL)includeAncestors NS_DESIGNATED_INITIALIZER;

#pragma mark - Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL includesAncestors;

/*! Subclasses must override this. */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKBehaviorItem *behaviorItem;

/*!
 * Subclass must override this.  Returns method items for just the behavior, no
 * superclasses or protocols included.
 */
- (NSArray *)memberItemsForBehavior:(AKBehaviorItem *)behaviorItem;

/*! Subclasses must override this. */
+ (id)memberDocClass;

@end
