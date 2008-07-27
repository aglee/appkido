//
//  AKMemberNode.h
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDatabaseNode.h"

@class AKBehaviorNode;

@interface AKMemberNode : AKDatabaseNode
{
@private
    AKBehaviorNode *_owningBehavior;
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (AKBehaviorNode *)owningBehavior;
- (void)setOwningBehavior:(AKBehaviorNode *)behaviorNode;

@end
