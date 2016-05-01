/*
 * AKClassGeneralSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKClassGeneralSubtopic.h"

#import "DIGSLog.h"

#import "AKBehaviorGeneralDoc.h"
#import "AKClassItem.h"
#import "AKFileSection.h"
#import "AKHTMLConstants.h"

@implementation AKClassGeneralSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForClassItem:(AKClassItem *)classItem
{
    return [[self alloc] initWithClassItem:classItem];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassItem:(AKClassItem *)classItem
{
    if ((self = [super init]))
    {
        _classItem = classItem;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithClassItem:nil];
}


#pragma mark - AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    // Start with the default behavior.
    [super populateDocList:docList];

    // If we're looking at a class that spans multiple frameworks, add
    // doc names for those frameworks.
    NSString *classFrameworkName = _classItem.nameOfOwningFramework;

    for (NSString *extraFrameworkName in [_classItem namesOfAllOwningFrameworks])
    {
        if (![classFrameworkName isEqualToString:extraFrameworkName])
        {
            [self _addDocsForExtraFramework:extraFrameworkName toList:docList];
        }
    }
}

#pragma mark - AKBehaviorGeneralSubtopic methods

- (AKBehaviorItem *)behaviorItem
{
    return _classItem;
}

- (NSString *)htmlNameOfDescriptionSection
{
    return AKClassDescriptionHTMLSectionName;
}

- (NSString *)altHtmlNameOfDescriptionSection
{
    return AKClassDescriptionAlternateHTMLSectionName;
}

#pragma mark - Private methods

- (void)_addDocsForExtraFramework:extraFrameworkName
                           toList:(NSMutableArray *)docList
{
    AKFileSection *extraRootSection = [_classItem documentationAssociatedWithFrameworkNamed:extraFrameworkName];

    if (extraRootSection)
    {
        // Add docs that correspond to sections of the file section.
        for (AKFileSection *majorSection in [self pertinentChildSectionsOf:extraRootSection])
        {
            NSString *sectionName = [majorSection sectionName];
            AKBehaviorGeneralDoc *sectionDoc = [[AKBehaviorGeneralDoc alloc] initWithFileSection:majorSection
                                                                               extraFrameworkName:extraFrameworkName];
            NSInteger docIndex = [self indexOfDocWithName:sectionName];

            if (docIndex < 0)
            {
                [docList addObject:sectionDoc];
            }
            else
            {
                [docList insertObject:sectionDoc atIndex:(docIndex + 1)];
            }
        }
    }
}

@end
