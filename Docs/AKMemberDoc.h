/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTokenDoc.h"

@class AKBehaviorToken;
@class AKMemberItem;

/*!
 * self.token is an AKMemberItem.  self.behaviorToken is a behavior that has
 * that member, either directly or by inheritance.
 */
@interface AKMemberDoc : AKTokenDoc

@property (nonatomic, readonly, strong) AKBehaviorToken *behaviorToken;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithMemberItem:(AKMemberItem *)memberItem behaviorToken:(AKBehaviorToken *)behaviorToken NS_DESIGNATED_INITIALIZER;

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
