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

- (AKClassToken *)parentClassOfTopic
{
	return self.classToken.parentClass;
}

- (NSString *)name
{
	return self.classToken.name;
}

- (NSString *)stringToDisplayInDescriptionField
{
	return [NSString stringWithFormat:@"%@ class %@",
			self.classToken.frameworkName, self.classToken.name];
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

- (BOOL)browserCellShouldBeLeaf
{
	return !(self.classToken.hasChildClasses);
}

- (NSArray *)childTopics
{
	NSMutableArray *columnValues = [NSMutableArray array];

	NSArray *childClassTokens = [AKSortUtils arrayBySortingArray:[self.classToken childClasses]];
	for (AKClassToken *subclassToken in childClassTokens) {
		[columnValues addObject:[[AKClassTopic alloc] initWithClassToken:subclassToken]];
	}

	return columnValues;
}

#pragma mark - AKBehaviorTopic methods

- (NSString *)behaviorName
{
	return self.classToken.name;
}

- (AKToken *)topicToken
{
	return self.classToken;
}

- (NSArray *)arrayWithSubtopics
{
	return @[
			 [self subtopicWithName:AKGeneralSubtopicName
					   docListItems:[self _docListItemsForGeneralSubtopic]
							   sort:NO],
			 [self subtopicWithName:AKPropertiesSubtopicName
					   docListItems:self.classToken.propertyTokens
							   sort:YES],
			 [self subtopicWithName:AKClassMethodsSubtopicName
					   docListItems:self.classToken.classMethodTokens
							   sort:YES],
			 [self subtopicWithName:AKInstanceMethodsSubtopicName
					   docListItems:self.classToken.instanceMethodTokens
							   sort:YES],
			 [self subtopicWithName:AKDelegateMethodsSubtopicName
					   docListItems:self.classToken.documentedDelegateMethods
							   sort:YES],
			 [self subtopicWithName:AKNotificationsSubtopicName
					   docListItems:self.classToken.documentedNotifications
							   sort:YES],
			 [self subtopicWithName:AKBindingsSubtopicName
					   docListItems:self.classToken.documentedBindings
							   sort:YES],
			 ];
}

#pragma mark - AKPrefDictionary methods

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
