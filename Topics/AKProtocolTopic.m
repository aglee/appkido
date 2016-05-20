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
//              AKCreateSubtopic(AKDelegateMethodsSubtopicName, nil, YES),
//              AKCreateSubtopic(AKNotificationsSubtopicName, nil, YES),
//              AKCreateSubtopic(AKBindingsSubtopicName, nil, YES),
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
	AKHeaderFileDoc *headerFileDoc = [[AKHeaderFileDoc alloc] initWithBehaviorToken:self.protocolToken];

	return @[headerFileDoc];
}

@end
