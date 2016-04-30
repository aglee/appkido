/*
 * AKTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

#import "DIGSLog.h"

#import "AKClassItem.h"
#import "AKSubtopic.h"

@implementation AKTopic

#pragma mark -
#pragma mark String constants

NSString *AKTopicBrowserPathSeparator = @"/";

NSString *AKProtocolsTopicName         = @"Protocols";
NSString *AKInformalProtocolsTopicName = @"Informal Protocols";
NSString *AKFunctionsTopicName         = @"Functions";
NSString *AKGlobalsTopicName           = @"Types & Constants";

#pragma mark -
#pragma mark Getters and setters

- (AKClassItem *)parentClassOfTopic
{
    return nil;
}

- (AKDocSetTokenItem *)topicNode
{
    return nil;
}

#pragma mark -
#pragma mark Names for various display contexts

- (NSString *)stringToDisplayInTopicBrowser
{
    DIGSLogError_MissingOverride();
    return @"??";
}

- (NSString *)stringToDisplayInDescriptionField
{
    return @"...";
}

- (NSString *)stringToDisplayInLists
{
    return [self stringToDisplayInTopicBrowser];
}

#pragma mark -
#pragma mark Populating the topic browser

- (NSString *)pathInTopicBrowser
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (BOOL)browserCellShouldBeEnabled
{
    return YES;
}

- (BOOL)browserCellHasChildren
{
    return YES;
}

- (NSArray *)childTopics
{
    return nil;
}

#pragma mark -
#pragma mark Subtopics

- (NSInteger)numberOfSubtopics
{
    return 0;
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSInteger)indexOfSubtopicWithName:(NSString *)subtopicName
{
    if (subtopicName == nil)
    {
        return -1;
    }

    NSInteger numSubtopics = [self numberOfSubtopics];
    NSInteger i;

    for (i = 0; i < numSubtopics; i++)
    {
        AKSubtopic *subtopic = [self subtopicAtIndex:i];

        if ([[subtopic subtopicName] isEqualToString:subtopicName])
        {
            return i;
        }
    }

    // If we got this far, the search failed.
    return -1;
}

- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName
{
    NSInteger subtopicIndex = ((subtopicName == nil)
                               ? -1
                               : [self indexOfSubtopicWithName:subtopicName]);
    return ((subtopicIndex < 0)
            ? nil
            : [self subtopicAtIndex:subtopicIndex]);
}

#pragma mark -
#pragma mark AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    NSString *topicClassName = prefDict[AKTopicClassNamePrefKey];

    if (topicClassName == nil)
    {
        DIGSLogWarning(@"missing name of topic class");
        return nil;
    }

    Class topicClass = NSClassFromString(topicClassName);
    if (topicClass == nil)
    {
        DIGSLogInfo(@"couldn't find a class called %@", topicClassName);
        return nil;
    }
    else
    {
        Class cl = topicClass;

        while ((cl = [cl superclass]) != nil)
        {
            if (cl == [AKTopic class])
            {
                break;
            }
        }

        if (cl == nil)
        {
            DIGSLogWarning(@"%@ is not a proper descendant class of AKTopic", topicClassName);
            return nil;
        }
    }

    return (AKTopic *)[topicClass fromPrefDictionary:prefDict];
}

- (NSDictionary *)asPrefDictionary
{
    DIGSLogError_MissingOverride();
    return nil;
}

#pragma mark -
#pragma mark AKSortable methods

- (NSString *)sortName
{
    return [self stringToDisplayInLists];
}

#pragma mark -
#pragma mark NSObject methods

- (BOOL)isEqual:(id)anObject
{
    if (![anObject isKindOfClass:[AKTopic class]])
    {
        return NO;
    }

    // Compare topics by comparing their browser paths.
    return ([[anObject pathInTopicBrowser] isEqualToString:[self pathInTopicBrowser]]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: browserPath=%@>", self.className, [self pathInTopicBrowser]];
}

@end
