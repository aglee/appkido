//
//  AKInferredTokenInfo.m
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKInferredTokenInfo.h"
#import "DocSetModel.h"
#import "DIGSLog.h"
#import "AKTopicConstants.h"

@implementation AKInferredTokenInfo

@synthesize tokenMO = _tokenMO;
@synthesize nodeName = _nodeName;
@synthesize frameworkChildTopicName = _frameworkChildTopicName;
@synthesize nameOfClass = _nameOfClass;
@synthesize nameOfProtocol = _nameOfProtocol;
@synthesize headerFileName = _headerFileName;
@synthesize nodeSubject = _nodeSubject;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
    NSParameterAssert(tokenMO != nil);
	self = [super init];
	if (self) {
		_tokenMO = tokenMO;
		_nodeName = tokenMO.parentNode.kName;

		[self _inferIvarsFromNodeName];

		if (_nodeSubject == nil) {
			_nodeSubject = _nodeName;
		}
	}
	return self;
}

#pragma mark - Private methods -- inferring info from tokens

// Called from init, hence all the direct ivar accesses.
- (void)_inferIvarsFromNodeName
{
	NSMutableArray *words = [[_nodeName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
	[words removeObject:@""];  // In case there are double spaces in the original string.
	NSString *nextToLastWord = (words.count >= 2 ? words[words.count - 2] : nil);

	// If it doesn't end with "Reference" we don't know how to parse it any further.
	if (![words.lastObject isEqualToString:@"Reference"]) {
		//QLog(@"+++ Node name '%@' doesn't end with 'Reference'.", _nodeName);  //TODO: Fix when this happens.
        _nodeSubject = _nodeName;
		return;
	}

	// "CLASSNAME Class Reference"
	if ([nextToLastWord isEqualToString:@"Class"]) {
		if (words.count != 3) {
			QLog(@"+++ Will assume '%@' is not about an ObjC class (wrong number of words).", _nodeName);
            _nodeSubject = [self _stringByRemovingLast:1 fromWords:words];
			return;
        }

        _nameOfClass = words[0];
        _nodeSubject = _nameOfClass;
        return;
	}

	// "PROTOCOLNAME Protocol Reference"
	// "PROTOCOLNAME Informal Protocol Reference"
	if ([nextToLastWord isEqualToString:@"Protocol"]) {
		BOOL seemsLikeObjCProtocol = NO;

		if (words.count == 4) {
			if ([words[1] isEqualToString:@"Informal"]) {
				seemsLikeObjCProtocol = YES;
			} else {
				//QLog(@"+++ Will assume '%@' is not about an ObjC protocol (second word is not 'Informal').", _nodeName);
				seemsLikeObjCProtocol = NO;
			}
		} else if (words.count != 3) {
			QLog(@"+++ Will assume '%@' is not about an ObjC protocol (wrong number of words).", _nodeName);
			seemsLikeObjCProtocol = NO;
		} else {
			seemsLikeObjCProtocol = YES;
		}

		if (seemsLikeObjCProtocol) {
            _nameOfProtocol = words[0];
            _nodeSubject = _nameOfProtocol;
            return;
        } else {
            _nodeSubject = [self _stringByRemovingLast:1 fromWords:words];
            return;
        }

		return;
	}

	// "FRAMEWORKNAME CHILDTOPIC Reference"
//TODO: I don't *think* this turned out to be needed, but should double-check, by comparing export with and without -- once I get export working again.
//	static NSSet *s_childTopicNames;
//	if (s_childTopicNames == nil) {
//		s_childTopicNames = [NSSet setWithObjects:AKEnumsTopicName, AKMacrosTopicName, AKConstantsTopicName, nil];
//	}
//	if (words.count == 3
//		&& [s_childTopicNames containsObject:words[1]])
//	{
//        _frameworkName = words[0];
//		_frameworkChildTopicName = words[1];
//		_nodeSubject = [@[words[0], words[1]] componentsJoinedByString:@" "];
//		return;
//	}
//    if (words.count == 4
//        && [words[1] isEqualToString:@"Data"]
//        && [words[2] isEqualToString:@"Types"])
//    {
//        _frameworkName = words[0];
//        _frameworkChildTopicName = AKDataTypesTopicName;
//        _nodeSubject = [@[words[0], AKDataTypesTopicName] componentsJoinedByString:@" "];
//        return;
//    }

	// "FRAMEWORKNAME Additions Reference"  //TODO: Fill this in.
	if (words.count == 3
		&& [words[1] isEqualToString:@"Additions"])
    {
        _frameworkName = words[0];
	}

	// "XXX.h Reference"
	if (words.count == 2 && [[words[0] pathExtension] isEqualToString:@"h"])
	{
		_headerFileName = words[0];
		_nodeSubject = _headerFileName;
		return;
	}

	// Fallback case: drop the word "Reference", and that's what the node is about.
	if (words.count > 1) {
		_nodeSubject = [self _stringByRemovingLast:1 fromWords:words];
		return;
	}
}

- (NSString *)_stringByRemovingLast:(NSInteger)numWordsToRemove fromWords:(NSArray *)words
{
	return [[words subarrayWithRange:NSMakeRange(0, words.count - numWordsToRemove)]
			componentsJoinedByString:@" "];
}

@end
