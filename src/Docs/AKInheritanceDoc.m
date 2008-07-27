/*
 * AKInheritanceDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKInheritanceDoc.h"

@implementation AKInheritanceDoc

//-------------------------------------------------------------------------
// AKOverviewDoc methods
//-------------------------------------------------------------------------

// The "Inheritance" doc uses the root section of the HTML file.  If we
// were to include descendant sections, we'd be displaying the whole file.
- (BOOL)textIncludesDescendantSections
{
    return NO;
}

- (NSString *)_unqualifiedDocName
{
    return @"Inheritance";
}

@end
