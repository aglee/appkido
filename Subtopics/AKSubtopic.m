/*
 * AKSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"
#import "DIGSLog.h"
#import "AKNamedObject.h"

@interface AKSubtopic ()
@property (copy, readonly) NSArray *docList;
@end

@implementation AKSubtopic

@synthesize docList = _docList;

#pragma mark - AKXyzSubtopicName

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
NSString *AKBindingsSubtopicName           = @"Bindings";
NSString *AKAllBindingsSubtopicName        = @"ALL Bindings";

#pragma mark - Getters and setters

- (NSString *)subtopicName
{
	DIGSLogError_MissingOverride();
	return nil;
}

- (NSString *)stringToDisplayInSubtopicList
{
	return [self subtopicName];
}

- (NSArray *)docList
{
	// Lazy loading.
	if (_docList == nil) {
		NSMutableArray *arrayOfDocs = [[NSMutableArray alloc] init];
		[self populateDocList:arrayOfDocs];
		_docList = arrayOfDocs;
	}
	return _docList;
}

#pragma mark - Docs

- (NSInteger)numberOfDocs
{
	return self.docList.count;
}

- (AKNamedObject *)docAtIndex:(NSInteger)docIndex
{
	return self.docList[docIndex];
}

- (NSInteger)indexOfDocWithName:(NSString *)docName
{
	if (docName == nil) {
		return -1;
	}

	NSInteger numDocs = self.docList.count;
	NSInteger i;

	for (i = 0; i < numDocs; i++) {
		AKNamedObject *doc = self.docList[i];
		if ([doc.name isEqualToString:docName]) {
			return i;
		}
	}

	// If we got this far, the search failed.
	return -1;
}

- (AKNamedObject *)docWithName:(NSString *)docName
{
	NSInteger docIndex = (docName == nil
						  ? -1
						  : [self indexOfDocWithName:docName]);

	return (docIndex < 0) ? nil : [self docAtIndex:docIndex];
}

- (void)populateDocList:(NSMutableArray *)docList
{
	DIGSLogError_MissingOverride();
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: subtopicName=%@>",
			self.className, self.subtopicName];
}

@end
