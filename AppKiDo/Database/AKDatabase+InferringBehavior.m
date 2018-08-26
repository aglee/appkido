//
//  AKDatabase+InferringBehavior.m
//  AppKiDo
//
//  Created by Andy Lee on 6/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKBehaviorInfo.h"
#import "AKCategoryToken.h"
#import "AKClassToken.h"
#import "AKProtocolToken.h"
#import "DIGSLog.h"
#import "NSArray+AppKiDo.h"

@implementation AKDatabase (InferringBehavior)

// Returns one of the following:
//
// - A class token.
// - A protocol token, perhaps because the member belongs to a category that we
//   have inferred is an informal protocol.
// - A category token.
// - nil if we can't figure out who should own the member token.
//
- (AKBehaviorToken *)_behaviorTokenFromInferredInfo:(AKBehaviorInfo *)behaviorInfo
{
	if (behaviorInfo.nameOfProtocol) {
		return [self _getOrAddProtocolTokenWithName:behaviorInfo.nameOfProtocol];
	}

	// If there's neither a protocol name nor a class name, we don't have enough to go on.
	if (behaviorInfo.nameOfClass == nil) {
		return nil;
	}

	// If there's only a class name, return a class token.
	AKClassToken *classToken = [self _getOrAddClassTokenWithName:behaviorInfo.nameOfClass];
	if (behaviorInfo.nameOfCategory == nil) {
		return classToken;
	}

	// If the category name matches a known protocol name, return that protocol.
	//TODO: Handle the case where there isn't a protocol but there should be, e.g. because the name ends with "Delegate".
	AKProtocolToken *protocolToken = [self protocolTokenWithName:behaviorInfo.nameOfCategory];
	if (protocolToken) {
		return protocolToken;
	}

	// The remaining case is that we have a "real" category.
	AKCategoryToken *categoryToken = [classToken categoryTokenWithName:behaviorInfo.nameOfCategory];
	if (categoryToken == nil) {
		categoryToken = [[AKCategoryToken alloc] initWithName:behaviorInfo.nameOfCategory];
		[classToken addCategoryToken:categoryToken];
	}
	return categoryToken;
}

- (AKBehaviorInfo *)_behaviorInfoInferredFromTokenMO:(DSAToken *)tokenMO
{
	AKBehaviorInfo *behaviorInfo = [[AKBehaviorInfo alloc] init];
	[self _initBehaviorInfo:behaviorInfo usingTokenMO:tokenMO];
	return behaviorInfo;
}

- (void)_initBehaviorInfo:(AKBehaviorInfo *)behaviorInfo usingTokenMO:(DSAToken *)tokenMO
{
	NSString *nodeName = tokenMO.parentNode.kName;
	NSMutableArray *words = [[nodeName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
	[words removeObject:@""];  // In case there are double spaces in the original string.

	NSString *firstWord = words[0];
	NSString *nextToLastWord = (words.count >= 2 ? words[words.count - 2] : nil);

	// If it doesn't end with "Reference" we don't know how to parse it any further.
	if (![words.lastObject isEqualToString:@"Reference"]) {
		//QLog(@"+++ Node name '%@' doesn't end with 'Reference'.", nodeName);  //TODO: Fix when this happens.
		return;
	}

	// "CLASSNAME Class Reference"
	// "CLASSNAME(CATEGORYNAME) Class Reference"
	//
	// We check for the latter because there are cases where node name is like
	// "DRBurn(ImageContentCreation) Class Reference".  We assume the category
	// name is a category name.  It's up to the caller to figure out if it's
	// really an informal protocol name.
	if ([nextToLastWord isEqualToString:@"Class"]) {
		if (words.count != 3) {
			QLog(@"+++ Will assume '%@' is not about an ObjC class (wrong number of words).", nodeName);
			return;
		}

		NSDictionary *captureGroups = [self _parsePossibleCategoryName:firstWord];
		behaviorInfo.nameOfClass = captureGroups[@1];
		behaviorInfo.nameOfCategory = captureGroups[@2];
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
				//QLog(@"+++ Will assume '%@' is not about an ObjC protocol (second word is not 'Informal').", nodeName);
				seemsLikeObjCProtocol = NO;
			}
		} else if (words.count == 3) {
			seemsLikeObjCProtocol = YES;
		} else {
			QLog(@"+++ Will assume '%@' is not about an ObjC protocol (wrong number of words).", nodeName);
			seemsLikeObjCProtocol = NO;
		}

		if (seemsLikeObjCProtocol) {
			behaviorInfo.nameOfProtocol = firstWord;
		}
		return;
	}
}

@end
