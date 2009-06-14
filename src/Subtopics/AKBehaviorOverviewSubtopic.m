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

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

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

//-------------------------------------------------------------------------
// Utility methods
//-------------------------------------------------------------------------

- (NSArray *)pertinentChildSectionsOf:(AKFileSection *)rootSection
{
    NSArray *sectionsToOmit =
        [NSArray arrayWithObjects:
            AKContentsHTMLSectionName,
            AKClassMethodsHTMLSectionName,
            AKInstanceMethodsHTMLSectionName,
            AKDelegateMethodsHTMLSectionName,
            AKDelegateMethodsAlternateHTMLSectionName,
            AKNotificationsHTMLSectionName,
            nil];
    NSMutableArray *pertinentSections = [NSMutableArray array];
    NSEnumerator *en = [rootSection childSectionEnumerator];
    AKFileSection *childSection;

    while ((childSection = [en nextObject]))
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

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

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
    NSEnumerator *majorSectionEnum =
        [[self pertinentChildSectionsOf:rootSection]
            objectEnumerator];
    AKFileSection *majorSection;

    while ((majorSection = [majorSectionEnum nextObject]))
    {
        AKOverviewDoc *newDoc =
            [[[AKOverviewDoc alloc] initWithFileSection:majorSection]
                autorelease];
        [docList addObject:newDoc];
    }

    // Add the "Inheritance" option as the first item.
    // If the user selects this, we will display the selected node's
    // root file section for the given node.
    AKInheritanceDoc *inheritanceDoc =
        [[[AKInheritanceDoc alloc] initWithFileSection:rootSection]
            autorelease];

    [docList insertObject:inheritanceDoc atIndex:0];

    // If a subsection named "XXX Description" or "Overview" is present, move
    // it to the top.
    NSString *descriptionSectionName = [self htmlNameOfDescriptionSection];
    NSString *altDescriptionSectionName = [self altHtmlNameOfDescriptionSection];
    int numDocs = [docList count];
    int i;

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
            [[[AKHeaderFileDoc alloc]
                initWithFileSection:headerFileSection]
                autorelease];

        [docList addObject:headerFileDoc];
    }
}

@end

