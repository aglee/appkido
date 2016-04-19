/*
 * AKFileSectionDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFileSectionDoc.h"

#import "DIGSLog.h"
#import "AKFileSection.h"

@implementation AKFileSectionDoc

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithFileSection:(AKFileSection *)fileSection
{
    if ((self = [super init]))
    {
        _fileSection = fileSection;
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark AKDoc methods

- (AKFileSection *)fileSection
{
    return _fileSection;
}

@end
