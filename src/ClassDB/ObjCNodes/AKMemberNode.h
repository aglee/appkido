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

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

// [agl] TODO should really set owningBehavior in init method.
- (AKBehaviorNode *)owningBehavior;
- (void)setOwningBehavior:(AKBehaviorNode *)behaviorNode;

@end
