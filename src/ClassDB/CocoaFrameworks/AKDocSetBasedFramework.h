/*
 * AKDocSetBasedFramework.h
 *
 * Created by Andy Lee on 1/21/08.
 * Copyright (c) 2008 Andy Lee. All rights reserved.
 */

#import "AKFramework.h"

@class AKDocSetIndex;

@interface AKDocSetBasedFramework : AKFramework
{
    AKDocSetIndex *_docSetIndex;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithName:(NSString *)fwName
    docSetIndex:(AKDocSetIndex *)docSetIndex;

@end
