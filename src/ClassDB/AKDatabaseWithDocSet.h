//
//  AKDatabaseWithDocSet.h
//  AppKiDo
//
//  Created by Andy Lee on 7/31/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"

@class AKDocSetIndex;

@interface AKDatabaseWithDocSet : AKDatabase
{
@private
    AKDocSetIndex *_docSetIndex;
}

/*! Designated initializer. */
- (id)initWithDocSetIndex:(AKDocSetIndex *)docSetIndex;

@end
