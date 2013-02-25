/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKHeaderFileDoc.h"

@implementation AKHeaderFileDoc

#pragma mark -
#pragma mark AKOverviewDoc methods

- (BOOL)isPlainText
{
    return YES;
}

- (NSString *)_unqualifiedDocName
{
    return @"Header File";
}

@end
