/*
 * AKOverviewDoc.h
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKOverviewDoc.h"

#import "AKFrameworkConstants.h"
#import "AKTextUtils.h"

@implementation AKOverviewDoc


#pragma mark -
#pragma mark Init/awake/dealloc

// Designated initializer
- (id)initWithFileSection:(AKFileSection *)fileSection
    andExtraFrameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithFileSection:fileSection]))
    {
        _extraFrameworkName = frameworkName;
    }

    return self;
}

- (id)initWithFileSection:(AKFileSection *)fileSection
{
    return
        [self initWithFileSection:fileSection
            andExtraFrameworkName:nil];
}



#pragma mark -
#pragma mark Utility methods

+ (NSString *)qualifyDocName:(NSString *)docName withFrameworkName:(NSString *)frameworkName
{
    if (frameworkName == nil)
    {
        return docName;
    }
    else
    {
        return [NSString stringWithFormat:@"%@ [%@]", docName, frameworkName];
    }
}


#pragma mark -
#pragma mark AKDoc methods

// If we're a doc for something in an extra framework (as opposed to a main
// framework), qualify the docName with the name of the extra framework.
- (NSString *)docName
{
    return
        [[self class]
            qualifyDocName:[self _unqualifiedDocName]
            withFrameworkName:_extraFrameworkName];
}

- (NSString *)stringToDisplayInDocList
{
    // Trimming whitespace handles the case where there's a newline at the
    // end of the string after we de-HTMLize it, which causes the rest of the
    // string not to be displayed in the NSTableView cell.  So far I haven't
    // encountered any cases of internal newlines in doc names, so I don't
    // handle that case.
    NSString *displayableDocName =
        [[[self _unqualifiedDocName] ak_stripHTML] ak_trimWhitespace];

    if (_extraFrameworkName == nil)
    {
        return displayableDocName;
    }
    else
    {
        return
            [NSString stringWithFormat:@"    %@ [%@ Additions]",
                displayableDocName,
                _extraFrameworkName];
    }
}


#pragma mark -
#pragma mark Protected methods

- (NSString *)_unqualifiedDocName
{
    return [super docName];
}

@end
