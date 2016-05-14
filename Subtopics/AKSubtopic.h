/*
 * AKSubtopic.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKNamedObject;

/*!
 * Abstract class that represents a subtopic of an AKTopic. Different kinds of
 * topic have different kinds of subtopic.
 *
 * When a subtopic is selected in the subtopic list, the selected AKSubtopic
 * provides a list of AKNamedObjects used to populate the doc list, via the
 * populateDocList: method.
 */
@interface AKSubtopic : NSObject

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
@property (copy, readonly) NSString *subtopicName;

@property (copy, readonly) NSString *stringToDisplayInSubtopicList;

#pragma mark - Docs

@property (assign, readonly) NSInteger numberOfDocs;

- (AKNamedObject *)docAtIndex:(NSInteger)docIndex;

/*! Returns -1 if none found. */
- (NSInteger)indexOfDocWithName:(NSString *)docName;

- (AKNamedObject *)docWithName:(NSString *)docName;

/*! Subclasses must override. For internal use only. */
- (void)populateDocList:(NSMutableArray *)docList;

@end
