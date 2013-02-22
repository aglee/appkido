/*
 * AKClassOverviewSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKClassOverviewSubtopic.h"

#import "DIGSLog.h"

#import "AKClassNode.h"
#import "AKHTMLConstants.h"
#import "AKOverviewDoc.h"
#import "AKFileSection.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKClassOverviewSubtopic (Private)
- (void)_addDocsForExtraFramework:extraFrameworkName
    toList:(NSMutableArray *)docList;
@end

@implementation AKClassOverviewSubtopic


#pragma mark -
#pragma mark Factory methods

+ (id)subtopicForClassNode:(AKClassNode *)classNode
{
    return [[self alloc] initWithClassNode:classNode];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithClassNode:(AKClassNode *)classNode
{
    if ((self = [super init]))
    {
        _classNode = classNode;
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    // Start with the default behavior.
    [super populateDocList:docList];

    // If we're looking at a class that spans multiple frameworks, add
    // doc names for those frameworks.
    NSString *classFrameworkName = [_classNode owningFrameworkName];

    for (NSString *extraFrameworkName in [_classNode namesOfAllOwningFrameworks])
    {
        if (![classFrameworkName isEqualToString:extraFrameworkName])
        {
            [self _addDocsForExtraFramework:extraFrameworkName toList:docList];
        }
    }
}


#pragma mark -
#pragma mark AKBehaviorOverviewSubtopic methods

- (AKBehaviorNode *)behaviorNode
{
    return _classNode;
}

- (NSString *)htmlNameOfDescriptionSection
{
    return AKClassDescriptionHTMLSectionName;
}

- (NSString *)altHtmlNameOfDescriptionSection
{
    return AKClassDescriptionAlternateHTMLSectionName;
}

@end


#pragma mark -
#pragma mark Private methods

@implementation AKClassOverviewSubtopic (Private)

- (void)_addDocsForExtraFramework:extraFrameworkName
    toList:(NSMutableArray *)docList
{
    AKFileSection *extraRootSection = [_classNode documentationAssociatedWithFrameworkNamed:extraFrameworkName];

    if (extraRootSection)
    {
        // Add docs that correspond to sections of the file section.
        for (AKFileSection *majorSection in [self pertinentChildSectionsOf:extraRootSection])
        {
            NSString *sectionName = [majorSection sectionName];
            AKOverviewDoc *sectionDoc = [[AKOverviewDoc alloc] initWithFileSection:majorSection
                                                             andExtraFrameworkName:extraFrameworkName];

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

