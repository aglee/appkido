//
//  AKNodeDoc.h
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDoc.h"

@class AKDatabaseNode;

@interface AKNodeDoc : AKDoc
{
@private
    AKDatabaseNode *_databaseNode;
}

@property (nonatomic, readonly) AKDatabaseNode *databaseNode;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithNode:(AKDatabaseNode *)databaseNode;

@end
