//
//  AKInferredFrameworkInfo.m
//  AppKiDo
//
//  Created by Andy Lee on 6/11/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKInferredFrameworkInfo.h"
#import "AKTopicConstants.h"
#import "DocSetModel.h"

@implementation AKInferredFrameworkInfo

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
	NSParameterAssert(tokenMO != nil);
	self = [super init];
	if (self) {
		_tokenMO = tokenMO;
		[self _initFrameworkIvarsUsingTokenMO];
	}
	return self;
}

- (instancetype)init
{
	return [self initWithTokenMO:nil];
}

#pragma mark - Private methods - init




//TODO: remember ApplicationKit = AppKit



// Called from init, hence all the direct ivar accesses.  Assumes _tokenMO has been set.
- (void)_initFrameworkIvarsUsingTokenMO
{
	NSString *nodeName = _tokenMO.parentNode.kName;
	NSMutableArray *words = [[nodeName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
	[words removeObject:@""];  // In case there are double spaces in the original string.

	// If it doesn't end with "Reference" we don't know how to parse it any further.
	if (![words.lastObject isEqualToString:@"Reference"]) {
		//QLog(@"+++ Node name '%@' doesn't end with 'Reference'.", nodeName);  //TODO: Fix when this happens.
		return;
	}

	// "FRAMEWORKNAME CHILDTOPIC Reference"
	//TODO: I don't *think* this turned out to be needed, but should double-check, by comparing export with and without -- once I get export working again.
	static NSSet *s_childTopicNames;
	if (s_childTopicNames == nil) {
		s_childTopicNames = [NSSet setWithObjects:AKEnumsTopicName, AKMacrosTopicName, AKConstantsTopicName, nil];
	}
	if (words.count == 3
		&& [s_childTopicNames containsObject:words[1]])
	{
        _frameworkName = words[0];
		_frameworkChildTopicName = words[1];
		return;
	}
    if (words.count == 4
        && [words[1] isEqualToString:@"Data"]
        && [words[2] isEqualToString:@"Types"])
    {
        _frameworkName = words[0];
        _frameworkChildTopicName = AKDataTypesTopicName;
        return;
    }

	// "FRAMEWORKNAME Additions Reference"  //TODO: Fill this in.
	if (words.count == 3
		&& [words[1] isEqualToString:@"Additions"])
	{
		_frameworkName = words[0];
	}
}

@end
