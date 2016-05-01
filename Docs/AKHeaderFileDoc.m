/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKHeaderFileDoc.h"

NSString *AKHeaderFileDocName = @"Header File";

@implementation AKHeaderFileDoc

#pragma mark -
#pragma mark AKBehaviorGeneralDoc methods

- (BOOL)docTextIsHTML
{
    return NO;
}

- (NSString *)unqualifiedDocName
{
    return AKHeaderFileDocName;
}

@end
