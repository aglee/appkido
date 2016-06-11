//
//  AKInferredTokenInfo.m
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKInferredTokenInfo.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "AKTopicConstants.h"
#import "DocSetModel.h"
#import "DIGSLog.h"
#import "NSArray+AppKiDo.h"

@implementation AKInferredTokenInfo

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
    NSParameterAssert(tokenMO != nil);
	self = [super initWithTokenMO:tokenMO];
	if (self) {
		NSString *nodeName = self.tokenMO.parentNode.kName;

		[self _initIvarsUsingNodeName:nodeName];

		if (_nodeSubject == nil) {
			_nodeSubject = nodeName;
		}
	}
	return self;
}

#pragma mark - Parsing

+ (NSDictionary *)parsePossibleCategoryName:(NSString *)name
{
	// Workaround for a bug/quirk in the 10.11.4 docset.  The token named
	// "NSObjectIOBluetoothHostControllerDelegate" has token type "cl" but
	// is actually a category on NSObject.
	if ([name isEqualToString:@"NSObjectIOBluetoothHostControllerDelegate"]) {
		return @{ @1: @"NSObject",
				  @2: @"IOBluetoothHostControllerDelegate" };
	}

	// Use a regex to parse the class name and category name.
	static NSRegularExpression *s_regexForCategoryNames;
	static dispatch_once_t once;
	dispatch_once(&once,^{
		s_regexForCategoryNames = [AKRegexUtils constructRegexWithPattern:@"(%ident%)(?:\\((%ident%)\\))?"].object;
		NSAssert(s_regexForCategoryNames != nil, @"%s Failed to construct regex.", __PRETTY_FUNCTION__);
	});
	AKResult *result = [AKRegexUtils matchRegex:s_regexForCategoryNames toEntireString:name];
	NSDictionary *captureGroups = result.object;
	return captureGroups;
}

#pragma mark - Private methods - init

// Called from init, hence all the direct ivar accesses.
- (void)_initIvarsUsingNodeName:(NSString *)nodeName
{
	NSMutableArray *words = [[nodeName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
	[words removeObject:@""];  // In case there are double spaces in the original string.
	NSString *nextToLastWord = (words.count >= 2 ? words[words.count - 2] : nil);

	// If it doesn't end with "Reference" we don't know how to parse it any further.
	if (![words.lastObject isEqualToString:@"Reference"]) {
		//QLog(@"+++ Node name '%@' doesn't end with 'Reference'.", nodeName);  //TODO: Fix when this happens.
        _nodeSubject = nodeName;
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
			_nodeSubject = [[words ak_arrayByRemovingLast:1] ak_joinedBySpaces];
			return;
        }

		NSDictionary *captureGroups = [AKInferredTokenInfo parsePossibleCategoryName:words[0]];
		_nameOfClass = captureGroups[@1];
		_nameOfCategory = captureGroups[@2];
        _nodeSubject = words[0];
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
            _nameOfProtocol = words[0];
            _nodeSubject = _nameOfProtocol;
            return;
        } else {
            _nodeSubject = [[words ak_arrayByRemovingLast:1] ak_joinedBySpaces];
            return;
        }
	}

	// "XXX.h Reference"
	if (words.count == 2 && [[words[0] pathExtension] isEqualToString:@"h"])
	{
		_nodeSubject = words[0];
		return;
	}

	// Fallback case: drop the word "Reference", and that's what the node is about.
	if (words.count > 1) {
		_nodeSubject = [[words ak_arrayByRemovingLast:1] ak_joinedBySpaces];
		return;
	}
}

@end
