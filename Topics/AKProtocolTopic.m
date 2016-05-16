/*
 * AKProtocolTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKProtocolTopic.h"
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKBehaviorHeaderFile.h"
#import "AKDatabase.h"
#import "AKFrameworkConstants.h"
#import "AKProtocolToken.h"
#import "AKSubtopicConstants.h"

@interface AKProtocolTopic ()
@property (strong) AKProtocolToken *protocolToken;
@end

@implementation AKProtocolTopic

@synthesize protocolToken = _protocolToken;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithProtocolToken:(AKProtocolToken *)protocolToken
{
	self = [super init];
	if (self) {
		_protocolToken = protocolToken;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithProtocolToken:nil];
}

#pragma mark - AKTopic methods

- (NSString *)name
{
	return [NSString stringWithFormat:@"<%@>", self.protocolToken.name];
}

- (NSString *)stringToDisplayInDescriptionField
{
	NSString *stringFormat = (self.protocolToken.isInformal
							  ? @"%@ INFORMAL protocol <%@>"
							  : @"%@ protocol <%@>");
	return [NSString stringWithFormat:stringFormat,
			self.protocolToken.frameworkName, self.protocolToken.name];
}

- (NSString *)pathInTopicBrowser
{
	NSString *whichProtocols = (self.protocolToken.isInformal
								? AKInformalProtocolsTopicName
								: AKProtocolsTopicName);
	return [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
			AKTopicBrowserPathSeparator, self.protocolToken.frameworkName,
			AKTopicBrowserPathSeparator, whichProtocols,
			AKTopicBrowserPathSeparator, self.protocolToken.name];
}

- (BOOL)browserCellShouldBeLeaf
{
	return YES;
}

#pragma mark - AKBehaviorTopic methods

- (NSString *)behaviorName
{
	return self.protocolToken.name;
}

- (AKToken *)topicToken
{
	return self.protocolToken;
}

- (NSArray *)arrayWithSubtopics
{
	return @[
			 [self subtopicWithName:AKGeneralSubtopicName
					   docListItems:[self _docListItemsForGeneralSubtopic]
							   sort:NO],
			 [self subtopicWithName:AKPropertiesSubtopicName
					   docListItems:self.protocolToken.propertyTokens
							   sort:YES],
			 [self subtopicWithName:AKClassMethodsSubtopicName
					   docListItems:self.protocolToken.classMethodTokens
							   sort:YES],
			 [self subtopicWithName:AKInstanceMethodsSubtopicName
					   docListItems:self.protocolToken.instanceMethodTokens
							   sort:YES],

 // These subtopics are added to the list even though they don't
 // apply to protocols, only classes.  This way, if, say, "Bindings"
 // is selected, and the user navigates from a class to a protocol
 // and then to a class, the "Bindings" subtopic stays selected
 // because it was always on the list.  The idea is to keep as much
 // as possible the same as the user navigates around.
 //
 //TODO: Revisit this.  I'm thinking maybe this makes it look like
 // protocols can have bindings, etc. (or that I *think* they can),
 // when they can't.  One option would be to have a doc list with
 // just one item with a name like "(not applicable)" or something.
 //
 //TODO: Revisit the "ALL Instance Methods" etc. feature.
 //             [self subtopicWithName:AKDelegateMethodsSubtopicName
 //                       docListItems:nil
 //                               sort:YES],
 //             [self subtopicWithName:AKNotificationsSubtopicName
 //                       docListItems:nil
 //                               sort:YES],
 //             [self subtopicWithName:AKBindingsSubtopicName
 //                       docListItems:nil
 //                               sort:YES],
			 ];
}

#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
	if (prefDict == nil) {
		return nil;
	}

	NSString *protocolName = prefDict[AKBehaviorNamePrefKey];
	if (protocolName == nil) {
		DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
		return nil;
	}

	AKDatabase *db = [(AKAppDelegate *)NSApp.delegate appDatabase];  //TODO: Global database.
	AKProtocolToken *protocolToken = [db protocolWithName:protocolName];
	if (!protocolToken) {
		DIGSLogInfo(@"couldn't find a protocol in the database named %@", protocolName);
		return nil;
	}

	return [[self alloc] initWithProtocolToken:protocolToken];
}

#pragma mark - Private methods

- (NSArray *)_docListItemsForGeneralSubtopic
{
	AKBehaviorHeaderFile *headerFileDoc = [[AKBehaviorHeaderFile alloc] initWithBehaviorToken:self.protocolToken];

	return @[headerFileDoc];
}

@end
