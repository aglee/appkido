/*
 * AKBehaviorOverviewSubtopic.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

@class AKFileSection;
@class AKBehaviorNode;

/*!
 * @class       AKBehaviorOverviewSubtopic
 * @abstract    The "General" subtopic used when a class or protocol is
 *              the selected topic.
 * @discussion  The docs under an AKBehaviorOverviewSubtopic are
 *              determined by (1) what major sections are in the
 *              behavior's doc file and (2) whether the behavior is a
 *              class that belongs to more than one framework.
 *
 *              Regarding (1): The doc file for each behavior is
 *              organized into a standard sequence of sections such as
 *              "Class Description", "Method Types", "Class Methods", and
 *              so on.  Not every behavior doc has all these sections.
 *              Where they exist, the first few standard sections, with a
 *              bit of tweaking, are used as the doc list of an
 *              AKBehaviorOverviewSubtopic.  These are sections that
 *              provide a general introduction to the behavior.  The
 *              remaining standard sections are used as subtopics with
 *              their own doc lists -- the "Class Methods" subtopic, for
 *              example, with individual methods in its doc list.
 *
 *              Regarding (2): if, for example, a Foundation class is
 *              extended by an AppKit category, the overview docs for
 *              that AppKit extension will be added to the
 *              AKBehaviorOverviewSubtopic's doc list.
 */
@interface AKBehaviorOverviewSubtopic : AKSubtopic
{
}


#pragma mark -
#pragma mark Getters and setters

// must override
- (AKBehaviorNode *)behaviorNode;

// for internal use
- (NSString *)htmlNameOfDescriptionSection;

// for internal use
- (NSString *)altHtmlNameOfDescriptionSection;


#pragma mark -
#pragma mark Utility methods

// for internal use
- (NSArray *)pertinentChildSectionsOf:(AKFileSection *)rootSection;

@end
