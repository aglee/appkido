/*
 * AKHeaderFileDoc.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKHeaderFileDoc.h"
#import "AKToken.h"
#import "AKDatabase.h"

NSString *AKHeaderFileDocName = @"Header File";

@implementation AKHeaderFileDoc

- (instancetype)initWithToken:(AKToken *)token
{
	NSParameterAssert(token != nil);
	self = [super initWithName:AKHeaderFileDocName];
	if (self) {
		_token = token;
	}
	return self;
}

- (instancetype)initWithName:(NSString *)name
{
	return [self initWithToken:nil];
}

#pragma mark - <AKDoc> methods

- (NSString *)displayNameForDocList
{
	return self.name;
}

- (NSString *)commentString
{
	return @"";
}

- (NSURL *)docURLAccordingToDatabase:(AKDatabase *)database
{
	// From inspection of the HeaderPath entity instances in the 10.11.4 dsidx:
	//
	// - The headerPath is relative to an SDK directory, e.g. /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk.
	//
	// - For Swift tokens (55,905 of them in the 10.11.4 docset), the 	headerPath is not a path, but either "Swift" or a framework name.
	//
	// - There's a bunch of tokens that have *no* headerPath.  I think that's a bug in some cases, not sure if all cases.
	if (self.token.headerPathRelativeToSDK) {
		NSURL *baseURL = [NSURL fileURLWithPath:database.sdkBasePath];
		return [baseURL URLByAppendingPathComponent:self.token.headerPathRelativeToSDK];
	} else if (self.token.fullHeaderPathOutsideOfSDK) {
		return [NSURL fileURLWithPath:self.token.fullHeaderPathOutsideOfSDK];
	} else {
		return nil;
	}
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return AKHeaderFileDocName;
}

@end
