/*
 * AKSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

#import <DIGSLog.h>

#import "AKDoc.h"

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKSubtopic (Private)
- (void)_makeSureDocListIsReady;
@end


@implementation AKSubtopic

//-------------------------------------------------------------------------
// AKXyzSubtopicName
//-------------------------------------------------------------------------

NSString *AKOverviewSubtopicName        = @"General";
NSString *AKPropertiesSubtopicName      = @"Properties";
NSString *AKClassMethodsSubtopicName    = @"Class Methods";
NSString *AKInstanceMethodsSubtopicName = @"Instance Methods";
NSString *AKDelegateMethodsSubtopicName = @"Delegate Methods";
NSString *AKNotificationsSubtopicName   = @"Notifications";

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (void)dealloc
{
    [_docList release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)subtopicName
{
    DIGSLogMissingOverride();
    return nil;
}

- (NSString *)stringToDisplayInSubtopicList
{
    return [self subtopicName];
}

//-------------------------------------------------------------------------
// Managing the doc list
//-------------------------------------------------------------------------

- (int)numberOfDocs
{
    [self _makeSureDocListIsReady];

    return [_docList count];
}

- (AKDoc *)docAtIndex:(int)index
{
    [self _makeSureDocListIsReady];

    return [_docList objectAtIndex:index];
}

- (int)indexOfDocWithName:(NSString *)docName
{
    [self _makeSureDocListIsReady];

    if (docName == nil)
    {
        return -1;
    }

    int numDocs = [_docList count];
    int i;

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

    int docIndex =
        (docName == nil)
        ? -1
        : [self indexOfDocWithName:docName];

    return (docIndex < 0) ? nil : [self docAtIndex:docIndex];
}

//-------------------------------------------------------------------------
// Protected methods
//-------------------------------------------------------------------------

- (void)populateDocList:(NSMutableArray *)docList
{
    DIGSLogMissingOverride();
}

//-------------------------------------------------------------------------
// NSObject methods
//-------------------------------------------------------------------------

- (NSString *)description
{
    return
        [NSString stringWithFormat:
            @"<%@: subtopicName=%@>",
            [self className],
            [self subtopicName]];
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKSubtopic (Private)

- (void)_makeSureDocListIsReady
{
    if (_docList == nil)
    {
        _docList = [[NSMutableArray array] retain];
        [self populateDocList:_docList];
    }
}

@end
