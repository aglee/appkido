/*
 * AKProtocolTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKProtocolTopic.h"
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKHeaderFileDoc.h"
#import "AKDatabase.h"
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
	NSParameterAssert(protocolToken != nil);
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

- (AKToken *)topicToken
{
	return self.protocolToken;
}

- (NSString *)stringToDisplayInDescriptionField
{
	return [NSString stringWithFormat:@"%@ protocol <%@>",
			self.protocolToken.frameworkName, self.protocolToken.name];
}

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
			AKTopicBrowserPathSeparator, self.protocolToken.frameworkName,
			AKTopicBrowserPathSeparator, AKProtocolsTopicName,
			AKTopicBrowserPathSeparator, self.protocolToken.name];
}

- (NSArray *)_arrayWithSubtopics
{
	return @[
			 AKCreateSubtopic(AKGeneralSubtopicName,
							  [self _docListItemsForGeneralSubtopic],
							  NO),
			 AKCreateSubtopic(AKPropertiesSubtopicName,
							  self.protocolToken.propertyTokens,
							  YES),
			 AKCreateSubtopic(AKClassMethodsSubtopicName,
							  self.protocolToken.classMethodTokens,
							  YES),
			 AKCreateSubtopic(AKInstanceMethodsSubtopicName,
							  self.protocolToken.instanceMethodTokens,
							  YES),
			 AKCreateSubtopic(AKDataTypesSubtopicName,
							  self.protocolToken.dataTypeTokens,
							  YES),
			 AKCreateSubtopic(AKConstantsSubtopicName,
							  self.protocolToken.constantTokens,
							  YES),
			 AKCreateSubtopic(AKNotificationsSubtopicName,
							  self.protocolToken.notificationTokens,
							  YES),
			 ];
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return self.protocolToken.name;
}

- (NSString *)displayName
{
	return self.protocolToken.displayName;
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

	AKDatabase *db = AKAppDelegate.appDelegate.appDatabase;  //TODO: Global database.
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
	AKHeaderFileDoc *headerFileDoc = [[AKHeaderFileDoc alloc] initWithToken:self.protocolToken];
	
	// Make the token itself the first doc in the doc list.  When it's selected,
	// the doc view will go to the top of the doc page for that token.
	return @[ self.protocolToken, headerFileDoc ];
}

@end
