//
// AKToken.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKToken.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"

@implementation AKToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
	NSParameterAssert(tokenMO != nil);
	self = [super initWithName:tokenMO.tokenName];
	if (self) {
		_tokenMO = tokenMO;
	}
	return self;
}

#pragma mark - Getters and setters

- (NSString *)headerPathRelativeToSDK
{
	return self.tokenMO.metainformation.declaredIn.headerPath;
}

- (BOOL)hasHeader
{
	return (self.fullHeaderPathOutsideOfSDK != nil
			|| self.headerPathRelativeToSDK != nil);
}

#pragma mark - Matching URLs

// Example: clicked on a link to NSMutableDictionary.
//
// Link URL was file:///Users/alee/Library/Developer/Shared/Documentation/DocSets/com.apple.adc.documentation.OSX.docset/Contents/Resources/Documents/documentation/Cocoa/Reference/Foundation/Classes/NSMutableDictionary_Class/index.html#//apple_ref/doc/c_ref/NSMutableDictionary
//
// Search results had one result, with this anchor: //apple_ref/occ/cl/NSMutableDictionary,
// which doesn't pass the first test of exactly matching anchors.  But the file
// path was
// documentation/Cocoa/Reference/Foundation/Classes/NSMutableDictionary_Class/index.html,
// which passed the second test.
- (BOOL)matchesLinkURL:(NSURL *)linkURL
{
	// Ideally the anchors match exactly.
	NSString *linkAnchor = linkURL.fragment;
	NSString *tokenAnchor = self.tokenMO.metainformation.anchor;

	//QLog(@"+++ link anchor: %@", linkAnchor);
	//QLog(@"+++ token anchor: %@", tokenAnchor);

	if ([linkAnchor isEqualToString:tokenAnchor]) {
		return YES;
	}

	// Next best thing: if the paths match, and the last components of the
	// anchors match.  The only way I can think of that this might fail is if
	// there are two tokens in the same doc file with the same name -- perhaps a
	// class method and an instance method.
	NSString *linkPath = linkURL.path;
	NSString *tokenRelativeDocPath = self.tokenMO.metainformation.file.path;
	QLog(@"+++ link path: ...%@", [[linkPath componentsSeparatedByString:@"/documentation/"] lastObject]);  // for brevity, easier to eyeball the log
	QLog(@"+++ token doc path: %@", tokenRelativeDocPath);

	if ([linkPath hasSuffix:tokenRelativeDocPath]
		&& [linkAnchor.lastPathComponent isEqualToString:tokenAnchor.lastPathComponent])
	{
		return YES;
	}

	// If we got this far, we don't have a match.
	return NO;
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: name=%@ type=%@>", self.className, self.name, self.tokenMO.tokenType.typeName];
}

@end
