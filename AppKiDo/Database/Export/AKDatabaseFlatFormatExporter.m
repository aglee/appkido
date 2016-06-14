//
//  AKDatabaseFlatFormatExporter.m
//  AppKiDo
//
//  Created by Andy Lee on 6/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabaseFlatFormatExporter.h"
#import "AKBindingToken.h"
#import "AKCategoryToken.h"
#import "AKClassToken.h"
#import "AKClassMethodToken.h"
#import "AKDatabase.h"
#import "AKFramework.h"
#import "AKFunctionToken.h"
#import "AKInstalledSDK.h"
#import "AKInstanceMethodToken.h"
#import "AKMemberToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKNotificationToken.h"
#import "AKPropertyToken.h"
#import "AKProtocolToken.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"
#import "NSArray+AppKiDo.h"

@implementation AKDatabaseFlatFormatExporter

- (void)printContentsOfDatabase:(AKDatabase *)database
{
	[self printMetadataForDatabase:database];

	for (NSString *frameworkName in database.sortedFrameworkNames) {
		AKFramework *framework = [database frameworkWithName:frameworkName];
		[self _printProtocolsInFramework:framework indent:0];
		[self _printClassesInFramework:framework indent:0];
		[self _printFunctionsAndGlobalsInFramework:framework indent:0];
	}
}

#pragma mark - Private methods -- printing high-level outlines

- (void)_printProtocolsInFramework:(AKFramework *)framework indent:(NSInteger)indentLevel
{
	for (AKProtocolToken *protocolToken in framework.protocolsGroup.sortedObjects) {
		DIGSPrintTabIndented(indentLevel, @"[%@] %@",
							 protocolToken.frameworkName,
							 protocolToken.displayName);
		[self _printMembersOfExtendedBehaviorToken:protocolToken indent:indentLevel];
	}
}

- (void)_printClassesInFramework:(AKFramework *)framework indent:(NSInteger)indentLevel
{
	for (AKClassToken *classToken in framework.classesGroup.sortedObjects) {
		DIGSPrintTabIndented(indentLevel, @"[%@] %@ : %@",
							 classToken.frameworkName,
							 classToken.displayName,
							 classToken.superclassToken.displayName);
		[self _printMembersOfClassToken:classToken indent:indentLevel];
	}
}

- (void)_printFunctionsAndGlobalsInFramework:(AKFramework *)framework
									  indent:(NSInteger)indentLevel
{
	for (AKNamedObjectGroup *tokenGroup in framework.functionsAndGlobalsCluster.sortedGroups) {
		for (AKToken *token in tokenGroup.sortedObjects) {
			DIGSPrintTabIndented(indentLevel, @"[%@] [%@] %@",
								 token.frameworkName,
								 tokenGroup.name,
								 token.displayName);
		}
	}
}

#pragma mark - Private methods -- printing members of behaviors

- (void)_printMembersOfBaseBehaviorToken:(AKBehaviorToken *)behaviorToken
								  indent:(NSInteger)indentLevel
{
	// Print members that all behaviors have.
	[self _printMemberTokens:behaviorToken.propertyTokens
			 ofBehaviorToken:behaviorToken
			 memberGroupName:nil
					  indent:indentLevel];
	[self _printMemberTokens:behaviorToken.classMethodTokens
			 ofBehaviorToken:behaviorToken
			 memberGroupName:nil
					  indent:indentLevel];
	[self _printMemberTokens:behaviorToken.instanceMethodTokens
			 ofBehaviorToken:behaviorToken
			 memberGroupName:nil
					  indent:indentLevel];
}

- (void)_printMembersOfExtendedBehaviorToken:(AKBehaviorToken *)behaviorToken
									  indent:(NSInteger)indentLevel
{
	// Print members that all behaviors have.
	[self _printMembersOfBaseBehaviorToken:behaviorToken indent:indentLevel];

	// Print additional members that protocols and classes have.
	[self _printMemberTokens:behaviorToken.dataTypeTokens
			 ofBehaviorToken:behaviorToken
			 memberGroupName:@"data type"
					  indent:indentLevel];
	[self _printMemberTokens:behaviorToken.constantTokens
			 ofBehaviorToken:behaviorToken
			 memberGroupName:@"constant"
					  indent:indentLevel];
	[self _printMemberTokens:behaviorToken.notificationTokens
			 ofBehaviorToken:behaviorToken
			 memberGroupName:@"notification"
					  indent:indentLevel];
}

- (void)_printMembersOfClassToken:(AKClassToken *)classToken indent:(NSInteger)indentLevel
{
	// Print members that protocols and classes have.
	[self _printMembersOfExtendedBehaviorToken:classToken indent:indentLevel];

	// Print members that only classes have.
	[self _printMemberTokens:classToken.delegateProtocolTokens
			 ofBehaviorToken:classToken
			 memberGroupName:@"delegate"
					  indent:indentLevel];
	[self _printMemberTokens:classToken.bindingTokens
			 ofBehaviorToken:classToken
			 memberGroupName:@"binding"
					  indent:indentLevel];
}

- (void)_printMemberTokens:(NSArray *)memberTokens
		   ofBehaviorToken:(AKBehaviorToken *)behaviorToken
		   memberGroupName:(NSString *)memberGroupName
					indent:(NSInteger)indentLevel
{
	if (memberGroupName) {
		// It's a "pseudo-member" (binding, notification, etc.).  Include the
		// group name and token type.
		for (AKMemberToken *memberToken in memberTokens) {
			DIGSPrintTabIndented(indentLevel, @"[%@] %@ [%@] %@ (type=%@)",
								 behaviorToken.frameworkName,
								 behaviorToken.displayName,
								 memberGroupName,
								 memberToken.displayName,
								 memberToken.tokenMO.tokenType.typeName);
		}
	} else {
		// It's a "real" member (property or method).  Its displayName will be
		// punctuated in a way that makes it clear what it is.
		for (AKMemberToken *memberToken in memberTokens) {
			DIGSPrintTabIndented(indentLevel, @"[%@] %@ %@",
								 behaviorToken.frameworkName,
								 behaviorToken.displayName,
								 memberToken.displayName);
		}
	}
}

@end
