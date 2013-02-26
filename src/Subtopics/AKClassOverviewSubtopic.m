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

@implementation AKClassOverviewSubtopic

#pragma mark -
#pragma mark Factory methods

+ (id)subtopicForClassNode:(AKClassNode *)classNode
{
    return [[[self alloc] initWithClassNode:classNode] autorelease];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithClassNode:(AKClassNode *)classNode
{
    if ((self = [super init]))
    {
        _classNode = [classNode retain];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}

- (void)dealloc
{
    [_classNode release];

    [super dealloc];
}

#pragma mark -
#pragma mark AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    // Start with the default behavior.
    [super populateDocList:docList];

    // If we're looking at a class that spans multiple frameworks, add
    // doc names for those frameworks.
    NSString *classFrameworkName = [_classNode nameOfOwningFramework];

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

#pragma mark -
#pragma mark Private methods

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
            AKOverviewDoc *sectionDoc = [[[AKOverviewDoc alloc] initWithFileSection:majorSection
                                                              andExtraFrameworkName:extraFrameworkName]
                                         autorelease];
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
