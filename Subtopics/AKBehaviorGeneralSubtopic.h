/*
 * AKBehaviorGeneralSubtopic.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

@class AKBehaviorItem;

/*!
 * The "General" subtopic displayed at the top of the subtopic list when a class
 * or protocol is the selected topic. This is an abstract class with subclasses
 * AKClassGeneralSubtopic and AKProtocolGeneralSubtopic.
 *
 * The docs under an AKBehaviorGeneralSubtopic are determined by (1) what major
 * sections are in the behavior's doc file and (2) whether the behavior is a
 * class that belongs to more than one framework.
 *
 * Regarding (1): The doc file for each behavior is organized into a standard
 * sequence of sections such as "Class Description", "Method Types",
 * "Class Methods", and so on.  Not every behavior doc has all these sections.
 * Where they exist, the first few standard sections, with a bit of tweaking,
 * are used as the doc list of an AKBehaviorGeneralSubtopic. These are sections
 * that provide a general introduction to the behavior. The remaining standard
 * sections are used as subtopics with their own doc lists -- "Class Methods",
 * for example, whose doc list containsn individual methods.
 *
 * Regarding (2): if, for example, a Foundation class is extended by an AppKit
 * category, the overview docs for that AppKit extension will be added to the
 * doc list.
 */
@interface AKBehaviorGeneralSubtopic : AKSubtopic

#pragma mark - Getters and setters

/*! Subclasses must override. */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKBehaviorItem *behaviorItem;

@end
