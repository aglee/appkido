/*
 * AKClassTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassTopic.h"
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKHeaderFileDoc.h"
#import "AKClassToken.h"
#import "AKDatabase.h"
#import "AKSubtopicConstants.h"
#import "NSArray+AppKiDo.h"

@interface AKClassTopic ()
@property (strong, readonly) AKClassToken *classToken;
@end

@implementation AKClassTopic

@synthesize classToken = _classToken;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassToken:(AKClassToken *)classToken
{
	NSParameterAssert(classToken != nil);
	self = [super init];
	if (self) {
		_classToken = classToken;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithClassToken:nil];
}

#pragma mark - AKTopic methods

- (AKToken *)topicToken
{
	return self.classToken;
}

- (AKClassToken *)superclassTokenForTopicToken
{
	return self.classToken.superclassToken;
}

- (NSString *)pathInTopicBrowser
{
	if (self.classToken == nil) {
		return nil;
	}

	NSString *path = [AKTopicBrowserPathSeparator stringByAppendingString:self.classToken.name];
	AKClassToken *classToken = self.classToken;

	while ((classToken = classToken.superclassToken)) {
		path = [AKTopicBrowserPathSeparator stringByAppendingString:
				[classToken.name stringByAppendingString:path]];
	}

	return path;
}

- (NSString *)stringToDisplayInDescriptionField
{
	return [NSString stringWithFormat:@"%@ class %@",
			self.classToken.frameworkName, self.classToken.name];
}

- (NSArray *)_arrayWithChildTopics
{
	NSMutableArray *childTopics = [NSMutableArray array];

	NSArray *subclassTokens = [self.classToken.subclassTokens ak_sortedBySortName];
	for (AKClassToken *subclassToken in subclassTokens) {
		[childTopics addObject:[[AKClassTopic alloc] initWithClassToken:subclassToken]];
	}

	return childTopics;
}

- (NSArray *)_arrayWithSubtopics
{
	return @[
			 AKCreateSubtopic(AKGeneralSubtopicName,
							  [self _docListItemsForGeneralSubtopic],
							  NO),
			 AKCreateSubtopic(AKPropertiesSubtopicName,
							  self.classToken.propertyTokens,
							  YES),
			 AKCreateSubtopic(AKClassMethodsSubtopicName,
							  self.classToken.classMethodTokens,
							  YES),
			 AKCreateSubtopic(AKInstanceMethodsSubtopicName,
							  self.classToken.instanceMethodTokens,
							  YES),
			 AKCreateSubtopic(AKDelegateMethodsSubtopicName,
							  self.classToken.delegateMethodTokens,
							  YES),
			 AKCreateSubtopic(AKDataTypesSubtopicName,
							  self.classToken.dataTypeTokens,
							  YES),
			 AKCreateSubtopic(AKConstantsSubtopicName,
							  self.classToken.constantTokens,
							  YES),
			 AKCreateSubtopic(AKNotificationsSubtopicName,
							  self.classToken.notificationTokens,
							  YES),
			 AKCreateSubtopic(AKBindingsSubtopicName,
							  self.classToken.bindingTokens,
							  YES),
			 ];
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return self.classToken.name;
}

#pragma mark - <AKPrefDictionary> methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
	if (prefDict == nil) {
		return nil;
	}

	NSString *className = prefDict[AKBehaviorNamePrefKey];
	if (className == nil) {
		DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
		return nil;
	}

	AKDatabase *db = AKAppDelegate.appDelegate.appDatabase;  //TODO: Global database.
	AKClassToken *classToken = [db classWithName:className];
	if (classToken == nil) {
		DIGSLogInfo(@"couldn't find a class in the database named %@", className);
		return nil;
	}

	return [[self alloc] initWithClassToken:classToken];
}

#pragma mark - Private methods

- (NSArray *)_docListItemsForGeneralSubtopic
{
	AKHeaderFileDoc *headerFileDoc = [[AKHeaderFileDoc alloc] initWithToken:self.classToken];

	// Make the token itself the first doc in the doc list.  When it's selected,
	// the doc view will go to the top of the doc page for that token.
	return @[ self.classToken, headerFileDoc ];
}

@end
