/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTokenDoc.h"

@class AKBehaviorItem;
@class AKMemberItem;

/*!
 * self.token is an AKMemberItem.  self.behaviorItem is a behavior that has
 * that member, either directly or by inheritance.
 */
@interface AKMemberDoc : AKTokenDoc

@property (nonatomic, readonly, strong) AKBehaviorItem *behaviorItem;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithMemberItem:(AKMemberItem *)memberItem behaviorItem:(AKBehaviorItem *)behaviorItem NS_DESIGNATED_INITIALIZER;

#pragma mark - Manipulating token names

/*! By default returns the token name unchanged. */
+ (NSString *)punctuateTokenName:(NSString *)tokenName;

#pragma mark - AKDoc methods

/*!
 * This implementation of -commentString assumes the receiver represents a
 * method.  Subclasses of AKMemberDoc for which this is not true need to
 * override this method.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *commentString;

@end
