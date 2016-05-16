/*
 * AKClassTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassTopic.h"
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKBehaviorHeaderFile.h"
#import "AKClassToken.h"
#import "AKDatabase.h"
#import "AKSortUtils.h"
#import "AKSubtopicConstants.h"

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

- (AKClassToken *)parentClassOfTopic
{
	return self.classToken.parentClass;
}

- (NSString *)pathInTopicBrowser
{
	if (self.classToken == nil) {
		return nil;
	}

	NSString *path = [AKTopicBrowserPathSeparator stringByAppendingString:self.classToken.name];
	AKClassToken *classToken = self.classToken;

	while ((classToken = classToken.parentClass)) {
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
	NSMutableArray *columnValues = [NSMutableArray array];

	NSArray *childClassTokens = [AKSortUtils arrayBySortingArray:[self.classToken childClasses]];
	for (AKClassToken *subclassToken in childClassTokens) {
		[columnValues addObject:[[AKClassTopic alloc] initWithClassToken:subclassToken]];
	}

	return columnValues;
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
							  self.classToken.documentedDelegateMethods,
							  YES),
			 AKCreateSubtopic(AKNotificationsSubtopicName,
							  self.classToken.documentedNotifications,
							  YES),
			 AKCreateSubtopic(AKBindingsSubtopicName,
							  self.classToken.documentedBindings,
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

	AKDatabase *db = [(AKAppDelegate *)NSApp.delegate appDatabase];  //TODO: Global database.
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
	AKBehaviorHeaderFile *headerFileDoc = [[AKBehaviorHeaderFile alloc] initWithBehaviorToken:self.classToken];

	return @[headerFileDoc];
}

@end
