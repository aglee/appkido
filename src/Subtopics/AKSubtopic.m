/*
 * AKSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

#import "DIGSLog.h"

#import "AKDoc.h"

@implementation AKSubtopic

#pragma mark -
#pragma mark AKXyzSubtopicName

NSString *AKGeneralSubtopicName            = @"General";
NSString *AKPropertiesSubtopicName         = @"Properties";
NSString *AKAllPropertiesSubtopicName      = @"ALL Properties";
NSString *AKClassMethodsSubtopicName       = @"Class Methods";
NSString *AKAllClassMethodsSubtopicName    = @"ALL Class Methods";
NSString *AKInstanceMethodsSubtopicName    = @"Instance Methods";
NSString *AKAllInstanceMethodsSubtopicName = @"ALL Instance Methods";
NSString *AKDelegateMethodsSubtopicName    = @"Delegate Methods";
NSString *AKAllDelegateMethodsSubtopicName = @"ALL Delegate Methods";
NSString *AKNotificationsSubtopicName      = @"Notifications";
NSString *AKAllNotificationsSubtopicName   = @"ALL Notifications";

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
#pragma mark Docs

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

    NSInteger docIndex = ((docName == nil)
                          ? -1
                          : [self indexOfDocWithName:docName]);

    return (docIndex < 0) ? nil : [self docAtIndex:docIndex];
}

- (void)populateDocList:(NSMutableArray *)docList
{
    DIGSLogError_MissingOverride();
}

#pragma mark -
#pragma mark NSObject methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: subtopicName=%@>",
            [self className],[self subtopicName]];
}

#pragma mark -
#pragma mark Private methods

- (void)_makeSureDocListIsReady
{
    if (_docList == nil)
    {
        _docList = [[NSMutableArray alloc] init];
        [self populateDocList:_docList];
    }
}

@end
