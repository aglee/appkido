//
//  AKTokenInferredInfo.m
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKTokenInferredInfo.h"
#import "AKClassToken.h"
#import "AKDatabase.h"
#import "AKProtocolToken.h"
#import "AKTopicConstants.h"
#import "DIGSLog.h"

@interface AKTokenInferredInfo ()
@property (strong) AKDatabase *database;
@property (copy) NSString *frameworkChildTopicName;
@property (strong) AKBehaviorToken *behaviorToken;
@property (copy) NSString *headerFileName;
@property (copy) NSString *referenceSubject;
@end

@implementation AKTokenInferredInfo

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO database:(AKDatabase *)database
{
	self = [super init];
	if (self) {
		_nodeName = tokenMO.parentNode.kName;
		_database = database;

		[self _inferOtherIvarsFromNodeName];
	}
	return self;
}

#pragma mark - Private methods

- (void)_inferOtherIvarsFromNodeName
{
	NSMutableArray *words = [[_nodeName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
	[words removeObject:@""];

	NSString *lastWord = words.lastObject;
	NSString *firstWord = words.firstObject;
	NSString *nextToLastWord = (words.count >= 2 ? words[words.count - 2] : nil);

	// If it doesn't end with "Reference" we don't know how to parse it any further.
	if (![lastWord isEqualToString:@"Reference"]) {
		_referenceSubject = _nodeName;

		return;
	}

	// Does it end with "Class Reference"?
	if ([nextToLastWord isEqualToString:@"Class"]) {
		_behaviorToken = [_database classWithName:firstWord];
		if (_behaviorToken == nil) {
			QLog(@"+++ [ODD] Node name '%@' seems to be about class '%@', but there is no such class in the database.", _nodeName, firstWord);
		}

		_framework = [_database frameworkWithName:_behaviorToken.frameworkName];
		_referenceSubject = firstWord;

		if (words.count != 3) {
			QLog(@"+++ [ODD] Node name '%@' seems to be about class '%@', but does not have exactly 3 words.", _nodeName, firstWord);
		}

		return;
	}

	// Does it end with "Protocol Reference"?
	if ([nextToLastWord isEqualToString:@"Protocol"]) {
		_behaviorToken = [_database protocolWithName:firstWord];
		if (_behaviorToken == nil) {
			QLog(@"+++ [ODD] Node name '%@' seems to be about protocol '%@', but there is no such protocol in the database.", _nodeName, firstWord);
		}

		_framework = [_database frameworkWithName:_behaviorToken.frameworkName];
		_referenceSubject = firstWord;

		if (words.count != 3) {
			QLog(@"+++ [ODD] Node name '%@' seems to be about protocol '%@', but does not have exactly 3 words.", _nodeName, firstWord);
		}

		return;
	}

	// Is it of the form "<framework> <childtopic> Reference"?
	static NSSet *s_childTopicNames;
	if (s_childTopicNames == nil) {
		s_childTopicNames = [NSSet setWithObjects:AKEnumsTopicName, AKMacrosTopicName, AKTypedefsTopicName, AKConstantsTopicName, nil];
	}
	if (words.count == 3
		&& [_database frameworkWithName:firstWord] != nil
		&& [s_childTopicNames containsObject:nextToLastWord])
	{
		_framework = [_database frameworkWithName:firstWord];
		_frameworkChildTopicName = nextToLastWord;
		_referenceSubject = [@[firstWord, nextToLastWord] componentsJoinedByString:@" "];

		return;
	}

	// Is it of the form "<headerfilename> Reference"?
	if (words.count == 2 && [firstWord.pathExtension isEqualToString:@"h"])
	{
		_headerFileName = firstWord;
		_referenceSubject = _headerFileName;

		return;
	}

	// Fallback case: drop the word "Reference", and that's what the node is about.
	if (words.count >= 1) {
		_referenceSubject = [[words subarrayWithRange:NSMakeRange(0, words.count - 1)]
							 componentsJoinedByString:@" "];

		return;
	}
}

@end
