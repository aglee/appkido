/*
 * AKLabelTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKLabelTopic.h"

#import "DIGSLog.h"

@implementation AKLabelTopic


#pragma mark -
#pragma mark Factory methods

+ (AKLabelTopic *)topicWithLabel:(NSString *)label
{
    AKLabelTopic *obj = [[[self alloc] init] autorelease];

    [obj setLabel:label];

    return obj;
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (void)dealloc
{
    [_label release];

    [super dealloc];
}


#pragma mark -
#pragma mark Getters and setters

- (void)setLabel:(NSString *)label
{
    [label retain];
    [_label release];
    _label = label;
}


#pragma mark -
#pragma mark AKTopic methods

+ (AKTopic *)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    NSString *labelString = [prefDict objectForKey:AKLabelStringPrefKey];

    if (labelString == nil)
    {
        DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
        return nil;
    }
    else
    {
        return [self topicWithLabel:labelString];
    }
}

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    [prefDict setObject:[self className] forKey:AKTopicClassNamePrefKey];
    [prefDict setObject:_label forKey:AKLabelStringPrefKey];

    return prefDict;
}

- (NSString *)stringToDisplayInTopicBrowser
{
    return _label;
}

- (NSString *)pathInTopicBrowser
{
    return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator, _label];
}

- (BOOL)browserCellShouldBeEnabled
{
    return NO;
}

- (BOOL)browserCellHasChildren
{
    return NO;
}


#pragma mark -
#pragma mark AKSortable methods

- (NSString *)sortName
{
    return _label;
}

@end
