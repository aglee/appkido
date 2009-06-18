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

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKClassOverviewSubtopic (Private)
- (void)_addDocsForExtraFramework:extraFrameworkName
    toList:(NSMutableArray *)docList;
@end

@implementation AKClassOverviewSubtopic

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)subtopicForClassNode:(AKClassNode *)classNode
{
    return [[[self alloc] initWithClassNode:classNode] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

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
    [self release];
    return nil;
}

- (void)dealloc
{
    [_classNode release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

- (void)populateDocList:(NSMutableArray *)docList
{
    // Start with the default behavior.
    [super populateDocList:docList];

    // If we're looking at a class that spans multiple frameworks, add
    // doc names for those frameworks.
    AKFramework *classFramework = [_classNode owningFramework];
    NSEnumerator *fwNameEnum = [[_classNode allOwningFrameworks] objectEnumerator];
    NSString *extraFrameworkName;

    while ((extraFrameworkName = [fwNameEnum nextObject]))
    {
        if (![classFramework isEqualToString:extraFrameworkName])
        {
            [self _addDocsForExtraFramework:extraFrameworkName toList:docList];
        }
    }
}

//-------------------------------------------------------------------------
// AKBehaviorOverviewSubtopic methods
//-------------------------------------------------------------------------

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

//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKClassOverviewSubtopic (Private)

- (void)_addDocsForExtraFramework:extraFrameworkName
    toList:(NSMutableArray *)docList
{
    AKFileSection *extraRootSection =
        [_classNode nodeDocumentationForFrameworkNamed:extraFrameworkName];

    if (extraRootSection)
    {
        NSArray *extraSections =
            [self pertinentChildSectionsOf:extraRootSection];
        NSEnumerator *sectionEnum = [extraSections objectEnumerator];
        AKFileSection *majorSection;

        // Add docs that correspond to sections of the file section.
        while ((majorSection = [sectionEnum nextObject]))
        {
            NSString *sectionName = [majorSection sectionName];
            AKOverviewDoc *sectionDoc =
                [[[AKOverviewDoc alloc]
                    initWithFileSection:majorSection
                    andExtraFrameworkName:extraFrameworkName]
                    autorelease];

            int index = [self indexOfDocWithName:sectionName];

            if (index < 0)
            {
                [docList addObject:sectionDoc];
            }
            else
            {
                [docList insertObject:sectionDoc atIndex:(index + 1)];
            }
        }
    }
}

@end

