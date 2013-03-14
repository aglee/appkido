//
//  AKRandomSearch.m
//  AppKiDo
//
//  Created by Andy Lee on 3/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKRandomSearch.h"

#import "DIGSLog.h"

#import "AKClassNode.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDocLocator.h"
#import "AKFileSection.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsNode.h"
#import "AKGlobalsTopic.h"
#import "AKGroupNode.h"
#import "AKMethodNode.h"
#import "AKProtocolNode.h"
#import "AKProtocolTopic.h"
#import "AKSubtopic.h"

#import "NSString+AppKiDo.h"

@implementation AKRandomSearch

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDatabase:(AKDatabase *)db
{
    if ((self = [super init]))
    {
        _database = [db retain];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}

- (void)dealloc
{
    [_database release];

    [super dealloc];
}

#pragma mark -
#pragma mark Searching

// Brute force -- make one huge array of doc locators and pick one.
- (AKDocLocator *)randomDocLocator
{
    NSMutableArray *allNodes = [NSMutableArray array];

    [self _addClassesToArray:allNodes];
    [self _addClassMembersToArray:allNodes];
    [self _addProtocolsToArray:allNodes];
    [self _addProtocolMembersToArray:allNodes];
    [self _addFunctionsToArray:allNodes];
    [self _addGlobalsToArray:allNodes];

    NSInteger randomArrayIndex = arc4random() % [allNodes count];

    return [allNodes objectAtIndex:randomArrayIndex];
}

#pragma mark -
#pragma mark Private methods

- (void)_addClassesToArray:(NSMutableArray *)_searchResults
{
    for (AKClassNode *classNode in [_database allClasses])
    {
        AKClassTopic *topic = [AKClassTopic topicWithClassNode:classNode];

        [_searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
    }
}

- (void)_addProtocolsToArray:(NSMutableArray *)_searchResults
{
    for (AKProtocolNode *protocolNode in [_database allProtocols])
    {
        AKProtocolTopic *topic = [AKProtocolTopic topicWithProtocolNode:protocolNode];

        [_searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
    }
}

- (void)_addClassMembersToArray:(NSMutableArray *)_searchResults
{
    for (AKClassNode *classNode in [_database allClasses])
    {
        AKClassTopic *topic = [AKClassTopic topicWithClassNode:classNode];

        // Search members common to all behaviors.
        [self _addMembersUnderBehaviorTopic:topic toArray:_searchResults];

        // Search members specific to classes.
        [self _addNodes:[classNode documentedDelegateMethods]
          underSubtopic:AKDelegateMethodsSubtopicName
        ofBehaviorTopic:topic
                toArray:_searchResults];
        [self _addNodes:[classNode documentedNotifications]
          underSubtopic:AKNotificationsSubtopicName
        ofBehaviorTopic:topic
                toArray:_searchResults];
    }
}

- (void)_addProtocolMembersToArray:(NSMutableArray *)_searchResults
{
    for (AKProtocolNode *protocolNode in [_database allProtocols])
    {
        AKProtocolTopic *topic = [AKProtocolTopic topicWithProtocolNode:protocolNode];

        [self _addMembersUnderBehaviorTopic:topic toArray:_searchResults];
    }
}

- (void)_addMembersUnderBehaviorTopic:(AKBehaviorTopic *)behaviorTopic
                              toArray:(NSMutableArray *)_searchResults
{
    AKBehaviorNode *behaviorNode = (AKBehaviorNode *)[behaviorTopic topicNode];

    // Search the behavior's properties.
    [self _addNodes:[behaviorNode documentedProperties]
      underSubtopic:AKPropertiesSubtopicName
    ofBehaviorTopic:behaviorTopic
            toArray:_searchResults];

    // Search the behavior's class methods.
    [self _addNodes:[behaviorNode documentedClassMethods]
      underSubtopic:AKClassMethodsSubtopicName
    ofBehaviorTopic:behaviorTopic
            toArray:_searchResults];

    // Search the behavior's instance methods.
    [self _addNodes:[behaviorNode documentedInstanceMethods]
      underSubtopic:AKInstanceMethodsSubtopicName
    ofBehaviorTopic:behaviorTopic
            toArray:_searchResults];
}

// Search the functions in each of the function groups for each framework.
- (void)_addFunctionsToArray:(NSMutableArray *)_searchResults
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupNode *groupNode in [_database functionsGroupsForFrameworkNamed:fwName])
        {
            for (AKDatabaseNode *subnode in [groupNode subnodes])
            {
                AKTopic *topic = [AKFunctionsTopic topicWithFrameworkNamed:fwName
                                                                inDatabase:_database];
                [_searchResults addObject:[AKDocLocator withTopic:topic
                                                     subtopicName:[groupNode nodeName]
                                                          docName:[subnode nodeName]]];
            }
        }
    }
}

// Search the globals in each of the groups of globals for each framework.
- (void)_addGlobalsToArray:(NSMutableArray *)_searchResults
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupNode *groupNode in [_database globalsGroupsForFrameworkNamed:fwName])
        {
            for (AKGlobalsNode *subnode in [groupNode subnodes])
            {
                AKTopic *topic = [AKGlobalsTopic topicWithFrameworkNamed:fwName
                                                              inDatabase:_database];
                [_searchResults addObject:[AKDocLocator withTopic:topic
                                                     subtopicName:[groupNode nodeName]
                                                          docName:[subnode nodeName]]];
            }
        }
    }
}

- (void)_addNodes:(NSArray *)nodeArray
    underSubtopic:(NSString *)subtopicName
  ofBehaviorTopic:(AKBehaviorTopic *)topic
          toArray:(NSMutableArray *)_searchResults
{
    for (AKDatabaseNode *node in nodeArray)
    {
        [_searchResults addObject:[AKDocLocator withTopic:topic
                                             subtopicName:subtopicName
                                                  docName:[node nodeName]]];
    }
}

@end
