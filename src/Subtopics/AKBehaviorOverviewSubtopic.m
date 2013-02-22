/*
 * AKBehaviorOverviewSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorOverviewSubtopic.h"

#import "DIGSLog.h"

#import "AKHTMLConstants.h"

#import "AKTextUtils.h"
#import "AKClassNode.h"
#import "AKFileSection.h"
#import "AKHeaderFileDoc.h"
#import "AKInheritanceDoc.h"

@implementation AKBehaviorOverviewSubtopic


#pragma mark -
#pragma mark Getters and setters

- (AKBehaviorNode *)behaviorNode
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSString *)htmlNameOfDescriptionSection
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSString *)altHtmlNameOfDescriptionSection
{
    DIGSLogError_MissingOverride();
    return nil;
}


#pragma mark -
#pragma mark Utility methods

- (NSArray *)pertinentChildSectionsOf:(AKFileSection *)rootSection
{
    NSArray *sectionsToOmit = (@[
                               AKContentsHTMLSectionName,
                               AKClassMethodsHTMLSectionName,
                               AKInstanceMethodsHTMLSectionName,
                               AKDelegateMethodsHTMLSectionName,
                               AKDelegateMethodsAlternateHTMLSectionName,
                               AKNotificationsHTMLSectionName,
                               ]);
    NSMutableArray *pertinentSections = [NSMutableArray array];

    for (AKFileSection *childSection in [rootSection childSections])
    {
        // There are some sections we don't want to list, because
        // they're accessed by a different navigation route.
        if (![sectionsToOmit containsObject:[childSection sectionName]])
        {
            [pertinentSections addObject:childSection];
        }
    }

    return pertinentSections;
}


#pragma mark -
#pragma mark AKSubtopic methods

- (NSString *)subtopicName
{
    return AKOverviewSubtopicName;
}

- (NSString *)stringToDisplayInSubtopicList
{
    return [@"1.  " stringByAppendingString:[self subtopicName]];
}

- (void)populateDocList:(NSMutableArray *)docList
{
    // Add whichever of the standard sections are available.
    AKFileSection *rootSection = [[self behaviorNode] nodeDocumentation];

    for (AKFileSection *majorSection in [self pertinentChildSectionsOf:rootSection])
    {
        [docList addObject:[[AKOverviewDoc alloc] initWithFileSection:majorSection]];
    }

    // Add the "Inheritance" option as the first item.
    // If the user selects this, we will display the selected node's
    // root file section for the given node.
    AKInheritanceDoc *inheritanceDoc =
        [[AKInheritanceDoc alloc] initWithFileSection:rootSection];

    [docList insertObject:inheritanceDoc atIndex:0];

    // If a subsection named "XXX Description" or "Overview" is present, move
    // it to the top.
    NSString *descriptionSectionName = [self htmlNameOfDescriptionSection];
    NSString *altDescriptionSectionName = [self altHtmlNameOfDescriptionSection];
    NSInteger numDocs = [docList count];
    NSInteger i;

    for (i = 0; i < numDocs; i++)
    {
        AKDoc *doc = [docList objectAtIndex:i];
        NSString *docName = [doc docName];

        if ([docName isEqualToString:descriptionSectionName]
                || [docName isEqualToString:altDescriptionSectionName])
        {
            if (i > 0)
            {
                [docList removeObjectAtIndex:i];
                [docList insertObject:doc atIndex:0];
            }

            break;
        }
    }

    // Add the "Header File" doc if appropriate.
    NSString *headerFilePath =
        [[self behaviorNode] headerFileWhereDeclared];

    if ([[NSFileManager defaultManager] fileExistsAtPath:headerFilePath])
    {
        AKFileSection *headerFileSection =
            [AKFileSection withEntireFile:headerFilePath];
        AKHeaderFileDoc *headerFileDoc =
            [[AKHeaderFileDoc alloc]
                initWithFileSection:headerFileSection];

        [docList addObject:headerFileDoc];
    }
}

@end

