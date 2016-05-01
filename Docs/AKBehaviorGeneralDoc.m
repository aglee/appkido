/*
 * AKBehaviorGeneralDoc.h
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorGeneralDoc.h"

#import "AKFrameworkConstants.h"

#import "NSString+AppKiDo.h"

@implementation AKBehaviorGeneralDoc

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFileSection:(AKFileSection *)fileSection extraFrameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithFileSection:fileSection]))
    {
        _extraFrameworkName = [frameworkName copy];
    }

    return self;
}

- (instancetype)initWithFileSection:(AKFileSection *)fileSection
{
    return [self initWithFileSection:fileSection extraFrameworkName:nil];
}


#pragma mark - Doc name

- (NSString *)unqualifiedDocName
{
    return [super docName];
}

#pragma mark - AKDoc methods

// If we're a doc for something in an extra framework (as opposed to a main
// framework), qualify the docName with the name of the extra framework.
- (NSString *)docName
{
    if (_extraFrameworkName == nil)
    {
        return [self unqualifiedDocName];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ [%@]", [self unqualifiedDocName], _extraFrameworkName];
    }
}

- (NSString *)stringToDisplayInDocList
{
    // Trimming whitespace handles the case where there's a newline at the
    // end of the string after we de-HTMLize it, which causes the rest of the
    // string not to be displayed in the NSTableView cell.  So far I haven't
    // encountered any cases of internal newlines in doc names, so I don't
    // handle that case.
    NSString *displayableDocName = [[[self unqualifiedDocName] ak_stripHTML] ak_trimWhitespace];

    if (_extraFrameworkName == nil)
    {
        return displayableDocName;
    }
    else
    {
        return [NSString stringWithFormat:@"    %@ [%@ Additions]",
                displayableDocName, _extraFrameworkName];
    }
}

@end
