//
//  AKMemberNode.h
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDatabaseNode.h"

@class AKBehaviorNode;

/*!
 * Stretches the concept of "member" slightly.  Used for properties, class
 * methods, instance methods, delegate methods, and notifications.
 */
@interface AKMemberNode : AKDatabaseNode

@property (nonatomic, readonly, weak) AKBehaviorNode *owningBehavior;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithNodeName:(NSString *)nodeName
       owningFramework:(AKFramework *)theFramework
        owningBehavior:(AKBehaviorNode *)behaviorNode;

@end
