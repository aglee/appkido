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
    [self release];
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
    AKFramework *classFramework = [_classNode owningFramework];
    NSEnumerator *fwNameEnum = [[_classNode allOwningFrameworks] objectEnumerator];
    NSString *extraFrameworkName;

    while ((extraFrameworkName = [fwNameEnum nextObject]))
    {
        if (![[classFramework frameworkName] isEqualToString:extraFrameworkName])
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

