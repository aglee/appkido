/*
 * AKMemberDoc.h
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKHeaderFileDoc.h"
#import "DocSetIndex.h"

NSString *AKHeaderFileDocName = @"Header File";

@implementation AKHeaderFileDoc

#pragma mark - AKBehaviorGeneralDoc methods

- (NSString *)unqualifiedDocName
{
	return AKHeaderFileDocName;
}

#pragma mark - AKDoc methods

- (NSURL *)docURLAccordingToDocSetIndex:(DocSetIndex *)docSetIndex
{
	// From inspection of the HeaderPath entity instances in the 10.11.4 dsidx:
	//
	// - The headerPath is relative to an SDK directory, e.g. /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk.
	//
	// - For Swift tokens (55,905 of them in the 10.11.4 docset), the 	headerPath is not a path, but either "Swift" or a framework name.
	//
	// - There's a bunch of tokens that have *no* headerPath.  I think that's a bug in some cases, not sure if all cases.
	NSString *relativePath = self.tokenItem.token.metainformation.declaredIn.headerPath;
	if ([relativePath hasPrefix:@"/"]) {
		return [docSetIndex.headerFilesBaseURL URLByAppendingPathComponent:relativePath];
	} else {
		return nil;
	}
}

@end
