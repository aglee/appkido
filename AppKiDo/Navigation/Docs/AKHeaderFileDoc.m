/*
 * AKHeaderFileDoc.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKHeaderFileDoc.h"
#import "AKBehaviorToken.h"
#import "AKDatabase.h"
#import "AKDoc.h"

NSString *AKHeaderFileDocName = @"Header File";

@implementation AKHeaderFileDoc

- (instancetype)initWithBehaviorToken:(AKBehaviorToken *)behaviorToken
{
	NSParameterAssert(behaviorToken != nil);
	NSString *relativePath = self.behaviorToken.relativeHeaderPath;
	NSString *headerFileName = relativePath.lastPathComponent;
	NSString *name = (headerFileName.length ? headerFileName : @"Header File");

	self = [super initWithName:name];
	if (self) {
		_behaviorToken = behaviorToken;
	}
	return self;
}

- (instancetype)initWithName:(NSString *)name
{
	return [self initWithBehaviorToken:nil];
}

#pragma mark - <AKDoc> methods

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
	NSString *relativePath = self.behaviorToken.relativeHeaderPath;
	if ([relativePath hasPrefix:@"/"]) {
		NSURL *baseURL = [NSURL fileURLWithPath:database.headerFilesBasePath];
		return [baseURL URLByAppendingPathComponent:relativePath];
	} else {
		return nil;
	}
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	NSString *headerFileName = self.behaviorToken.relativeHeaderPath.lastPathComponent;
	return (headerFileName ?: @"Header File");
}

@end
