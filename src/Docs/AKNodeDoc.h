//
//  AKNodeDoc.h
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDoc.h"

@class AKDatabaseNode;

@interface AKNodeDoc : AKDoc
{
@private
    AKDatabaseNode *_databaseNode;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithNode:(AKDatabaseNode *)databaseNode;

@end
