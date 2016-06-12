//
//  AKTabIndentedOutlineExport.m
//  AppKiDo
//
//  Created by Andy Lee on 6/11/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKTabIndentedOutlineExport.h"
#import "AKBindingToken.h"
#import "AKCategoryToken.h"
#import "AKClassToken.h"
#import "AKClassMethodToken.h"
#import "AKDatabase.h"
#import "AKFramework.h"
#import "AKFunctionToken.h"
#import "AKInstanceMethodToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKNotificationToken.h"
#import "AKPropertyToken.h"
#import "AKProtocolToken.h"
#import "DIGSLog.h"
#import "NSArray+AppKiDo.h"


// Categories on AKDatabase and various AKToken classes to support exporting
// basic info about most of the tokens in the database, one line per token, in a
// tab-indented outline.  The method to call is AKDatabase's debugExport.

#pragma mark -

static void ExportLog(NSInteger indentLevel, NSString *format, ...)
{
	va_list argList;
	va_start(argList, format);
	{{
		NSString *indent = [@"" stringByPaddingToLength:indentLevel
											 withString:@"\t"
										startingAtIndex:0];
		NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
		fprintf(stderr, "%s%s\n", indent.UTF8String, message.UTF8String);
	}}
	va_end(argList);
}


#pragma mark -

@implementation AKNamedObject (TabIndentedOutlineExport)

- (void)debugExportWithIndentLevel:(NSInteger)indentLevel
{
	ExportLog(indentLevel, @"%@ \"%@\"", self.className, self.name);
}

@end

#pragma mark -

@implementation AKDatabase (TabIndentedOutlineExport)

- (void)debugExport
{
	ExportLog(0, @"%@\n", [NSDate date]);
	[self debugExportWithIndentLevel:0];
}

- (void)debugExportWithIndentLevel:(NSInteger)indentLevel
{
	// Non-class info.
	for (NSString *frameworkName in self.sortedFrameworkNames) {
		AKFramework *framework = [self frameworkWithName:frameworkName];
		[framework debugExportWithIndentLevel:indentLevel];
	}

	// Classes.
	for (AKClassToken *classToken in [self.allClassTokens ak_sortedBySortName]) {
		[classToken debugExportWithIndentLevel:indentLevel];
	}
}

@end

#pragma mark -

@implementation AKFramework (TabIndentedOutlineExport)

- (void)debugExportWithIndentLevel:(NSInteger)indentLevel
{
	ExportLog(indentLevel, @"FRAMEWORK %@", self.name);

	// Protocols.
	for (AKProtocolToken *protocolToken in self.protocolsGroup.sortedObjects) {
		ExportLog(indentLevel + 1, @"PROTOCOL %@ [%@]", protocolToken.name, protocolToken.frameworkName);
	}

	// Functions and globals.
	for (AKNamedObjectGroup *tokenGroup in self.functionsAndGlobalsCluster.sortedGroups) {
		ExportLog(indentLevel + 1, @"GROUP \"%@\"", tokenGroup.name);
		for (AKToken *token in tokenGroup.sortedObjects) {
			ExportLog(indentLevel + 2, @"%@", token.name);
		}
	}
}

@end

#pragma mark -

@implementation AKClassToken (TabIndentedOutlineExport)

- (void)debugExportWithIndentLevel:(NSInteger)indentLevel
{
	ExportLog(indentLevel, @"CLASS %@ : %@ [%@]", self.name, self.superclassToken.name, self.frameworkName);

	// Categories.
	for (AKToken *token in [self.categoryTokensImmediateOnly ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"CATEGORY %@ [%@]", token.displayName, token.frameworkName);
	}

	// Properties.
	for (AKToken *token in [self.propertyTokens ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"PROPERTY %@", token.displayName);
	}

	// Class methods.
	for (AKToken *token in [self.classMethodTokens ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"CLASS METHOD %@", token.displayName);
	}

	// Instance methods.
	for (AKToken *token in [self.instanceMethodTokens ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"INSTANCE METHOD %@", token.displayName);
	}

	// Data types.
	for (AKToken *token in [self.dataTypeTokens ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"DATA TYPE %@", token.displayName);
	}

	// Constants.
	for (AKToken *token in [self.constantTokens ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"CONSTANT %@", token.displayName);
	}

	// Notifications.
	for (AKToken *token in [self.notificationTokens ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"NOTIFICATION %@", token.displayName);
	}

	// Delegate protocols.
	for (AKToken *token in [self.delegateProtocolTokens ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"DELEGATE PROTOCOL %@", token.displayName);
	}

	// Bindings.
	for (AKToken *token in [self.bindingTokens ak_sortedBySortName]) {
		ExportLog(indentLevel + 1, @"BINDING %@", token.displayName);
	}
}

@end

