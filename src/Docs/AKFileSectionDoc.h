/*
 * AKFileSectionDoc.h
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDoc.h"

@interface AKFileSectionDoc : AKDoc
{
@private
    AKFileSection *_fileSection;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithFileSection:(AKFileSection *)fileSection;

//-------------------------------------------------------------------------
// AKDoc methods
//-------------------------------------------------------------------------

- (AKFileSection *)fileSection;

@end
