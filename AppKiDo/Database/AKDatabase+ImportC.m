//
//  AKDatabase+ObjectiveC.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKClassToken.h"
#import "AKFramework.h"
#import "AKFunctionToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKNotificationToken.h"
#import "AKProtocolToken.h"
#import "AKTokenInferredInfo.h"
#import "DIGSLog.h"

@implementation AKDatabase (ImportC)

- (void)_importCTokens
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"C" tokenType:nil]) {
		// Special case: "tag" tokens.  As far as I can tell, they are redundant
		// with other tags, so I'm going to ignore them until I learn otherwise.
		if ([tokenMO.tokenType.typeName isEqualToString:@"tag"]) {
			continue;
		}

		// Infer some info about the token.
		AKTokenInferredInfo *inferredInfo = [[AKTokenInferredInfo alloc] initWithTokenMO:tokenMO];
		if (inferredInfo.frameworkName == nil) {
			inferredInfo.frameworkName = [self _frameworkNameForTokenMO:tokenMO];
		}
		if (inferredInfo.frameworkName == nil) {
			continue;
		}

		// Is it a function?
		AKToken *token;
		token = [self _maybeAddFunctionTokenWithInferredInfo:inferredInfo];
		if (token) {
			continue;
		}

		// Is it a notification?
		token = [self _maybeAddNotificationWithInferredInfo:inferredInfo];
		if (token) {
			continue;
		}

		// Does it belong to a behavior?
		token = [self _maybeAddTokenToBehaviorWithInferredInfo:inferredInfo];
		if (token) {
			continue;
		}

		// Add the token to one of the framework's bins.
		token = [self _maybeAddTokenToFrameworkWithInferredInfo:inferredInfo];
		if (token) {
			continue;
		}
	}
}

- (AKToken *)_maybeAddNotificationWithInferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	if (![inferredInfo.tokenMO.tokenName hasSuffix:@"Notification"]) {
		return nil;
	}

	AKBehaviorToken *behaviorToken = [self _behaviorTokenForInferredInfo:inferredInfo];
	if (behaviorToken) {
		// Attach the notification to its owning behavior.
		AKNotificationToken *notifToken = [[AKNotificationToken alloc] initWithTokenMO:inferredInfo.tokenMO];
		[behaviorToken addNotification:notifToken];
		return notifToken;
	} else {
		// Non-behavior notifications get lumped with the framework's other constants.
		AKToken *notifToken = [[AKToken alloc] initWithTokenMO:inferredInfo.tokenMO];
		NSString *groupName = inferredInfo.nodeSubject;  //TODO: Figure out the right group name.
		AKFramework *framework = [self _frameworkWithNameAddIfAbsent:inferredInfo.frameworkName];
		[framework.constantsCluster addNamedObject:notifToken toGroupWithName:groupName];
		return notifToken;
	}
}

- (AKToken *)_maybeAddFunctionTokenWithInferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	if (![inferredInfo.tokenMO.tokenType.typeName isEqualToString:@"func"]) {
		return nil;
	}

	AKToken *token = [[AKFunctionToken alloc] initWithTokenMO:inferredInfo.tokenMO];
	token.frameworkName = inferredInfo.frameworkName;

	NSString *groupName = inferredInfo.tokenMO.parentNode.kName;  //TODO: Figure out the right group name.
	AKFramework *framework = [self _frameworkWithNameAddIfAbsent:inferredInfo.frameworkName];
	[framework.functionsCluster addNamedObject:token toGroupWithName:groupName];

	return token;
}

- (AKBehaviorToken *)_behaviorTokenForInferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	if (inferredInfo.nameOfClass) {
		AKClassToken *classToken = [self classWithName:inferredInfo.nameOfClass];
		if (classToken == nil) {
			QLog(@"+++ [ODD] No class with name %@.", inferredInfo.nameOfClass);
			return nil;
		}
		return classToken;
	} else if (inferredInfo.nameOfProtocol) {
		AKProtocolToken *protocolToken = [self protocolWithName:inferredInfo.nameOfProtocol];
		if (protocolToken == nil) {
			QLog(@"+++ [ODD] No protocol with name %@.", inferredInfo.nameOfProtocol);
			return nil;
		}
		return protocolToken;
	} else {
		return nil;
	}
}

- (AKToken *)_maybeAddTokenToBehaviorWithInferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	AKBehaviorToken *behaviorToken = [self _behaviorTokenForInferredInfo:inferredInfo];
	if (behaviorToken == nil) {
		return nil;
	}

	AKToken *token = [[AKToken alloc] initWithTokenMO:inferredInfo.tokenMO];
	token.frameworkName = inferredInfo.frameworkName;

	NSString *tokenType = inferredInfo.tokenMO.tokenType.typeName;
	if ([tokenType isEqualToString:@"data"]
		|| [tokenType isEqualToString:@"econst"]
		|| [tokenType isEqualToString:@"macro"]) {

		[behaviorToken addConstantToken:token];
		//QLog(@"+++ Added constant %@ to %@.", token.name, behaviorToken);
	} else if ([tokenType isEqualToString:@"tdef"]) {
		[behaviorToken addDataTypeToken:token];
		//QLog(@"+++ Added data type %@ to %@.", token, behaviorToken);
	} else {
		//QLog(@"+++ [ODD] %s Unexpected token type %@ for %@.", tokenType, token);
		return nil;
	}

	return token;
}

- (AKToken *)_maybeAddTokenToFrameworkWithInferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	// Figure out which token cluster within the framework the token belongs to.
	AKFramework *framework = [self _frameworkWithNameAddIfAbsent:inferredInfo.frameworkName];
	NSDictionary *clustersByType = @{
									 @"data" : framework.constantsCluster,
									 @"econst" : framework.enumsCluster,
									 @"macro" : framework.macrosCluster,
									 @"tdef" : framework.dataTypesCluster,
									 };
	AKNamedObjectCluster *tokenCluster = clustersByType[inferredInfo.tokenMO.tokenType.typeName];
	if (tokenCluster == nil) {
		QLog(@"+++ Could not import token %@ -- framework %@ has no token bin for type %@.", inferredInfo.tokenMO.tokenName, framework.name, inferredInfo.tokenMO.tokenType.typeName);
		return nil;
	}

	// Create the token and add it to the framework.
	AKToken *token = [[AKToken alloc] initWithTokenMO:inferredInfo.tokenMO];
	token.frameworkName = inferredInfo.frameworkName;

	NSString *groupName = inferredInfo.nodeSubject;  //TODO: Figure out the right group name.
	[tokenCluster addNamedObject:token toGroupWithName:groupName];

	return token;
}

@end
