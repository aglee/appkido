/*
 * AKSubtopic.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKDoc;

/*!
 * Abstract class that represents a subtopic of an AKTopic. Different kinds of
 * topic have different kinds of subtopic.
 *
 * UI notes: when a subtopic is selected in the subtopic list, the selected
 * AKSubtopic provides a list of AKDocs used to populate the doc list.
 */
@interface AKSubtopic : NSObject
{
@private
    // Elements are AKDocs.  The array is lazily instantiated and populated by
    // populateDocList:.
    NSMutableArray *_docList;
}

#pragma mark - AKXyzSubtopicName

// Names of subtopics that are listed when the topic is a class or protocol.
extern NSString *AKGeneralSubtopicName;
extern NSString *AKPropertiesSubtopicName;
extern NSString *AKAllPropertiesSubtopicName;
extern NSString *AKClassMethodsSubtopicName;
extern NSString *AKAllClassMethodsSubtopicName;
extern NSString *AKInstanceMethodsSubtopicName;
extern NSString *AKAllInstanceMethodsSubtopicName;
extern NSString *AKDelegateMethodsSubtopicName;
extern NSString *AKAllDelegateMethodsSubtopicName;
extern NSString *AKNotificationsSubtopicName;
extern NSString *AKAllNotificationsSubtopicName;
extern NSString *AKBindingsSubtopicName;
extern NSString *AKAllBindingsSubtopicName;

#pragma mark - Getters and setters

/*! Subclasses must override. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *subtopicName;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringToDisplayInSubtopicList;

#pragma mark - Docs

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger numberOfDocs;

- (AKDoc *)docAtIndex:(NSInteger)docIndex;

/*! Returns -1 if none found. */
- (NSInteger)indexOfDocWithName:(NSString *)docName;

- (AKDoc *)docWithName:(NSString *)docName;

/*! Subclasses must override. For internal use only. */
- (void)populateDocList:(NSMutableArray *)docList;

@end
