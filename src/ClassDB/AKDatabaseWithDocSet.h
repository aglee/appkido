//
//  AKDatabaseWithDocSet.h
//  AppKiDo
//
//  Created by Andy Lee on 7/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDatabase.h"

@class AKDocSetIndex;

@interface AKDatabaseWithDocSet : AKDatabase
{
@private
    AKDocSetIndex *_docSetIndex;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithDocSetIndex:(AKDocSetIndex *)docSetIndex;

@end
