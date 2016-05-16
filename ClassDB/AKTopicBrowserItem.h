//
//  AKTopicBrowserItem.h
//  AppKiDo
//
//  Created by Andy Lee on 5/15/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamed.h"

@class AKClassToken;
@class AKSubtopic;
@class AKToken;

@protocol AKTopicBrowserItem <AKNamed>

@required

@property (strong, readonly) AKClassToken *parentClassOfTopic;  //TODO: KLUDGE
@property (strong, readonly) AKToken *topicToken;  //TODO: KLUDGE

@property (copy, readonly) NSString *stringToDisplayInDescriptionField;
@property (copy, readonly) NSString *pathInTopicBrowser;
@property (assign, readonly) BOOL browserCellShouldBeEnabled;
@property (assign, readonly) BOOL browserCellShouldBeLeaf;
/*! Array of AKTopics, or nil if the receiver is a leaf topic. */
@property (copy, readonly) NSArray *childTopics;
@property (assign, readonly) NSInteger numberOfSubtopics;

/*! Returns -1 if none found. */
- (NSInteger)indexOfSubtopicWithName:(NSString *)subtopicName;
- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex;
- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName;

@end
