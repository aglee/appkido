/*
 * AKSubtopic.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKDoc;

/*!
 * @class       AKSubtopic
 * @abstract    Encapsulates one of the subtopics listed in the subtopic
 *              list.
 * @discussion  Each row in the subtopic list is associated with an
 *              AKSubtopic.  (The subtopic list is the NSTableView
 *              on the left side of the middle section of the window;
 *              it is managed by an AKSubtopicListController.)
 *
 *              When a subtopic is selected in the subtopic list, the
 *              selected AKSubtopic provides a list of AKDocs used to
 *              populate the doc list.  (The doc list is the NSTableView
 *              to the right of the subtopic list; it is managed by an
 *              AKDocListController.)
 *
 *              AKSubtopic is an abstract class.  Subclasses represent
 *              different kinds of subtopics that may be listed in the
 *              subtopic list.
 */
@interface AKSubtopic : NSObject
{
@private
    // Elements are AKDocs.  The array is populated by populateDocList:.
    NSMutableArray *_docList;
}


#pragma mark -
#pragma mark AKXyzSubtopicName
//
// Names of standard subtopics that are listed when the topic is a
// class or protocol.

extern NSString *AKOverviewSubtopicName;
extern NSString *AKPropertiesSubtopicName;
extern NSString *AKClassMethodsSubtopicName;
extern NSString *AKInstanceMethodsSubtopicName;
extern NSString *AKDelegateMethodsSubtopicName;
extern NSString *AKNotificationsSubtopicName;


#pragma mark -
#pragma mark Getters and setters

// must override
- (NSString *)subtopicName;

- (NSString *)stringToDisplayInSubtopicList;


#pragma mark -
#pragma mark Managing the doc list

/*!
 * @method      numberOfDocs
 * @discussion  Returns the number of docs the doc list should display
 *              when this subtopic is selected.
 */
- (NSInteger)numberOfDocs;

- (AKDoc *)docAtIndex:(NSInteger)index;

/*!
 * @method      indexOfDocWithName:
 * @discussion  Returns the index within the doc list of the AKDoc with
 *              the specified name, or -1 if there is none.
 */
- (NSInteger)indexOfDocWithName:(NSString *)docName;

- (AKDoc *)docWithName:(NSString *)docName;

@end



#pragma mark -
#pragma mark Protected methods

@interface AKSubtopic (Protected)

/*!
 * @method      populateDocList:
 * @discussion  Subclasses must override this method.  It fills in the
 *              _docList array.
 *
 *              Methods that access _docList call this as needed.
 * @param       docList  An empty list that will be filled in by this
 *              method.
 */
- (void)populateDocList:(NSMutableArray *)docList;

@end
