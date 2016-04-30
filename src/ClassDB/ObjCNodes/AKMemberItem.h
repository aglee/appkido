//
//  AKMemberItem.h
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDocSetTokenItem.h"

@class AKBehaviorItem;

/*!
 * Represents a member (as in the term "member function") of a behavior.
 * Stretches the concept of "member" slightly.  Used not only for properties and
 * methods, but also for bindings, delegate methods and notifications.
 */
@interface AKMemberItem : AKDocSetTokenItem
{
@private
    __unsafe_unretained AKBehaviorItem *_owningBehavior;
}

@property (nonatomic, readonly, unsafe_unretained) AKBehaviorItem *owningBehavior;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName owningBehavior:(AKBehaviorItem *)behaviorItem NS_DESIGNATED_INITIALIZER;

@end
