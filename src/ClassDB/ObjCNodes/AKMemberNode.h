//
//  AKMemberNode.h
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDatabaseNode.h"

@class AKBehaviorNode;

/*!
 * Stretches the concept of "member" slightly.  Used for properties, class
 * methods, instance methods, delegate methods, and notifications.
 */
@interface AKMemberNode : AKDatabaseNode
{
@private
    AKBehaviorNode *_owningBehavior;
}


#pragma mark -
#pragma mark Init/awake/dealloc

/*!
 * @method      initWithNodeName:owningFramework:owningBehavior:
 * @discussion  Designated initializer.
 */
- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(AKFramework *)theFramework
    owningBehavior:(AKBehaviorNode *)behaviorNode;


#pragma mark -
#pragma mark Getters and setters

- (AKBehaviorNode *)owningBehavior;

@end
