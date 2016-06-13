//
//  AKDatabaseOutlineExporter.m
//  AppKiDo
//
//  Created by Andy Lee on 6/11/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabaseOutlineExporter.h"
#import "AKBindingToken.h"
#import "AKCategoryToken.h"
#import "AKClassToken.h"
#import "AKClassMethodToken.h"
#import "AKDatabase.h"
#import "AKFramework.h"
#import "AKFunctionToken.h"
#import "AKInstalledSDK.h"
#import "AKInstanceMethodToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKNotificationToken.h"
#import "AKPropertyToken.h"
#import "AKProtocolToken.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"
#import "NSArray+AppKiDo.h"

@implementation AKDatabaseOutlineExporter

- (void)printOutlineOfFrameworksInDatabase:(AKDatabase *)database
{
	[self printMetadataForDatabase:database];
	[self _printProtocolsInDatabase:database indent:0];
}

- (void)printOutlineOfProtocolsInDatabase:(AKDatabase *)database
{
	[self printMetadataForDatabase:database];
	[self _printProtocolsInDatabase:database indent:0];
}

- (void)printOutlineOfClassesInDatabase:(AKDatabase *)database
{
	[self printMetadataForDatabase:database];
	[self _printClassesInDatabase:database indent:0];
}

- (void)printFullOutlineOfDatabase:(AKDatabase *)database
{
	[self printMetadataForDatabase:database];
	[self _printFrameworksInDatabase:database indent:0];
	[self _printProtocolsInDatabase:database indent:0];
	[self _printClassesInDatabase:database indent:0];
}

#pragma mark - Private methods -- printing high-level outlines

- (void)_printFrameworksInDatabase:(AKDatabase *)database indent:(NSInteger)indentLevel
{
	DIGSPrintTabIndented(indentLevel, @"%@:", @"[Frameworks]");
	for (NSString *frameworkName in database.sortedFrameworkNames) {
		AKFramework *framework = [database frameworkWithName:frameworkName];
		[self _printFramework:framework indent:(indentLevel + 1)];
	}
}

- (void)_printFramework:(AKFramework *)framework indent:(NSInteger)indentLevel
{
	DIGSPrintTabIndented(indentLevel, @"%@ Framework:", framework.name);

	[self _printNamesWithTitle:@"Classes"
					tokenGroup:framework.classesGroup
						indent:(indentLevel + 1)];
	[self _printNamesWithTitle:@"Protocols"
					tokenGroup:framework.protocolsGroup
						indent:(indentLevel + 1)];

	DIGSPrintTabIndented(indentLevel + 1, @"%@", @"[Functions and Globals]");
	for (AKNamedObjectGroup *tokenGroup in framework.functionsAndGlobalsCluster.sortedGroups) {
		[self _printNamesWithTitle:tokenGroup.name
						tokenGroup:tokenGroup
							indent:(indentLevel + 2)];
	}
}

- (void)_printProtocolsInDatabase:(AKDatabase *)database indent:(NSInteger)indentLevel
{
	for (AKProtocolToken *protocolToken in [database.allProtocolTokens ak_sortedBySortName]) {
		DIGSPrintTabIndented(indentLevel, @"%@ [%@]:",
							 protocolToken.displayName,
							 protocolToken.frameworkName);
		[self _printMembersOfExtendedBehaviorToken:protocolToken indent:(indentLevel + 1)];
	}
}

- (void)_printClassesInDatabase:(AKDatabase *)database indent:(NSInteger)indentLevel
{
	for (AKClassToken *classToken in [database.allClassTokens ak_sortedBySortName]) {
		DIGSPrintTabIndented(indentLevel, @"%@ : %@ [%@]:",
							 classToken.displayName,
							 classToken.superclassToken.displayName,
							 classToken.frameworkName);
		[self _printMembersOfClassToken:classToken indent:(indentLevel + 1)];
	}
}

#pragma mark - Private methods -- printing members of behaviors

// Members common to protocols, classes, and categories.
- (void)_printMembersOfBaseBehaviorToken:(AKBehaviorToken *)behaviorToken
								  indent:(NSInteger)indentLevel
{
	[self _printNamesWithTitle:@"Properties"
						tokens:behaviorToken.propertyTokens
						indent:indentLevel];
	[self _printNamesWithTitle:@"Class Methods"
						tokens:behaviorToken.classMethodTokens
						indent:indentLevel];
	[self _printNamesWithTitle:@"Instance Methods"
						tokens:behaviorToken.instanceMethodTokens
						indent:indentLevel];
}

// Includes members common to protocols and classes.
- (void)_printMembersOfExtendedBehaviorToken:(AKBehaviorToken *)behaviorToken
									  indent:(NSInteger)indentLevel
{
	[self _printMembersOfBaseBehaviorToken:behaviorToken indent:indentLevel];

	[self _printNamesAndTypesWithTitle:@"Data Types"
								tokens:behaviorToken.dataTypeTokens
								indent:indentLevel];
	[self _printNamesAndTypesWithTitle:@"Constants"
								tokens:behaviorToken.constantTokens
								indent:indentLevel];
	[self _printNamesAndTypesWithTitle:@"Notifications"
								tokens:behaviorToken.notificationTokens
								indent:indentLevel];
}

// Includes members only classes have.
- (void)_printMembersOfClassToken:(AKClassToken *)classToken indent:(NSInteger)indentLevel
{
	[self _printMembersOfExtendedBehaviorToken:classToken indent:indentLevel];

	[self _printNamesAndTypesWithTitle:@"Delegate Protocols"
								tokens:classToken.delegateProtocolTokens
								indent:indentLevel];
	[self _printNamesAndTypesWithTitle:@"Bindings"
								tokens:classToken.bindingTokens
								indent:indentLevel];

	for (AKCategoryToken *categorytoken in [classToken.categoryTokensImmediateOnly ak_sortedBySortName]) {
		DIGSPrintTabIndented(indentLevel, @"[Category %@] [%@]",
							 categorytoken.name,
							 categorytoken.frameworkName);
		[self _printMembersOfBaseBehaviorToken:categorytoken indent:(indentLevel + 1)];
	}
}

#pragma mark - Private methods -- misc

- (void)_printTitle:(NSString *)title indent:(NSInteger)indentLevel
{
	DIGSPrintTabIndented(indentLevel, @"[%@]", title);
}

- (void)_printNamesWithTitle:(NSString *)title
					  tokens:(NSArray *)tokens
					  indent:(NSInteger)indentLevel
{
	[self _printTitle:title indent:indentLevel];
	for (AKToken *token in [tokens ak_sortedBySortName]) {
		DIGSPrintTabIndented(indentLevel + 1, @"%@ ", token.displayName);
	}
}

- (void)_printNamesWithTitle:(NSString *)title
				  tokenGroup:(AKNamedObjectGroup *)tokenGroup
					  indent:(NSInteger)indentLevel
{
	[self _printTitle:title indent:indentLevel];
	for (AKToken *token in tokenGroup.sortedObjects) {
		DIGSPrintTabIndented(indentLevel + 1, @"%@ ", token.displayName);
	}
}

- (void)_printNamesAndTypesWithTitle:(NSString *)title
							  tokens:(NSArray *)tokens
							  indent:(NSInteger)indentLevel
{
	[self _printTitle:title indent:indentLevel];
	for (AKToken *token in [tokens ak_sortedBySortName]) {
		DIGSPrintTabIndented(indentLevel + 1, @"%@ [type=%@]",
							 token.displayName,
							 token.tokenMO.tokenType.typeName);
	}
}

@end
