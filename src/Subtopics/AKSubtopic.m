/*
 * AKSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

#import "DIGSLog.h"

#import "AKDoc.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKSubtopic (Private)
- (void)_makeSureDocListIsReady;
@end


@implementation AKSubtopic


#pragma mark -
#pragma mark AKXyzSubtopicName

NSString *AKOverviewSubtopicName        = @"General";
NSString *AKPropertiesSubtopicName      = @"Properties";
NSString *AKClassMethodsSubtopicName    = @"Class Methods";
NSString *AKInstanceMethodsSubtopicName = @"Instance Methods";
NSString *AKDelegateMethodsSubtopicName = @"Delegate Methods";
NSString *AKNotificationsSubtopicName   = @"Notifications";


#pragma mark -
#pragma mark Init/awake/dealloc



#pragma mark -
#pragma mark Getters and setters

- (NSString *)subtopicName
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSString *)stringToDisplayInSubtopicList
{
    return [self subtopicName];
}


#pragma mark -
#pragma mark Managing the doc list

- (NSInteger)numberOfDocs
{
    [self _makeSureDocListIsReady];

    return [_docList count];
}

- (AKDoc *)docAtIndex:(NSInteger)docIndex
{
    [self _makeSureDocListIsReady];

    return [_docList objectAtIndex:docIndex];
}

- (NSInteger)indexOfDocWithName:(NSString *)docName
{
    [self _makeSureDocListIsReady];

    if (docName == nil)
    {
        return -1;
    }

    NSInteger numDocs = [_docList count];
    NSInteger i;

    for (i = 0; i < numDocs; i++)
    {
        AKDoc *doc = [_docList objectAtIndex:i];

        if ([[doc docName] isEqualToString:docName])
        {
            return i;
        }
    }

    // If we got this far, the search failed.
    return -1;
}

- (AKDoc *)docWithName:(NSString *)docName
{
    [self _makeSureDocListIsReady];

    NSInteger docIndex =
        (docName == nil)
        ? -1
        : [self indexOfDocWithName:docName];

    return (docIndex < 0) ? nil : [self docAtIndex:docIndex];
}


#pragma mark -
#pragma mark Protected methods

- (void)populateDocList:(NSMutableArray *)docList
{
    DIGSLogError_MissingOverride();
}


#pragma mark -
#pragma mark NSObject methods

- (NSString *)description
{
    return
        [NSString stringWithFormat:
            @"<%@: subtopicName=%@>",
            [self className],
            [self subtopicName]];
}

@end



#pragma mark -
#pragma mark Private methods

@implementation AKSubtopic (Private)

- (void)_makeSureDocListIsReady
{
    if (_docList == nil)
    {
        _docList = [NSMutableArray array];
        [self populateDocList:_docList];
    }
}

@end
