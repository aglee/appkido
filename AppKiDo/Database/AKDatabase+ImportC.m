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

@implementation AKDatabase (PrivateC)

- (void)_importCTokens
{
	for (DSAToken *tokenMO in [self _arrayWithTokenMOsForLanguage:@"C"]) {
		AKToken *token;

		// Special case: "tag" tokens.  As far as I can tell, they are redundant
		// with other tags, so I'm going to ignore them until I learn otherwise.
		if ([tokenMO.tokenType.typeName isEqualToString:@"tag"]) {
			continue;
		}

		// Figure out what context we can about the token.
		AKTokenInferredInfo *inferredInfo = [[AKTokenInferredInfo alloc] initWithTokenMO:tokenMO database:self];
		if (inferredInfo.framework == nil) {
			NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
			inferredInfo.framework = [self frameworkWithName:frameworkName];
		}
		if (inferredInfo.framework == nil) {
			continue;
		}

		// Is it a function token?
		token = [self _maybeAddFunctionTokenWithTokenMO:tokenMO toFramework:inferredInfo.framework];
		if (token) {
			continue;
		}

		// Is it a notification?
		token = [self _maybeAddNotificationWithTokenMO:tokenMO inferredInfo:inferredInfo];
		if (token) {
			continue;
		}

		// Create the AKToken and try to add it to the framework.
		token = [self _maybeLastChanceAddTokenWithTokenMO:tokenMO inferredInfo:inferredInfo];
		if (token) {
			continue;
		}
	}
}

- (AKToken *)_maybeAddNotificationWithTokenMO:(DSAToken *)tokenMO inferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	if (![tokenMO.tokenName hasSuffix:@"Notification"]) {
		return nil;
	}

	if (inferredInfo.behaviorToken) {
		// Attach the notification to its owning behavior.
		AKNotificationToken *notifToken = [[AKNotificationToken alloc] initWithTokenMO:tokenMO];
		[inferredInfo.behaviorToken addNotification:notifToken];
		return notifToken;
	} else {
		// Non-behavior notifications get lumped with the framework's other constants.
		AKToken *notifToken = [[AKToken alloc] initWithTokenMO:tokenMO];
//		NSString *groupName = tokenMO.parentNode.kName;  //TODO: Figure out the right group name.
		NSString *groupName = inferredInfo.referenceSubject;  //TODO: Figure out the right group name.
		[inferredInfo.framework.constantsCluster addNamedObject:notifToken
												toGroupWithName:groupName];
		return notifToken;
	}
}

- (AKToken *)_maybeAddFunctionTokenWithTokenMO:(DSAToken *)tokenMO toFramework:(AKFramework *)framework
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"func"]) {
		return nil;
	}

	AKToken *token = [[AKFunctionToken alloc] initWithTokenMO:tokenMO];
	token.frameworkName = framework.name;

	NSString *groupName = tokenMO.parentNode.kName;  //TODO: Figure out the right group name.
	[framework.functionsCluster addNamedObject:token toGroupWithName:groupName];

	return token;
}

- (AKToken *)_maybeLastChanceAddTokenWithTokenMO:(DSAToken *)tokenMO
									 inferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	// Figure out which token cluster within the framework the token belongs to.
	AKNamedObjectCluster *tokenCluster = [inferredInfo.framework tokenClusterWithTokenType:tokenMO.tokenType.typeName];
	if (tokenCluster == nil) {
		QLog(@"+++ Could not import token %@ -- framework %@ has no token bin for type %@.", tokenMO.tokenName, inferredInfo.framework.name, tokenMO.tokenType.typeName);
		return nil;
	}

	// Create the token and add it to the framework.
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	token.frameworkName = inferredInfo.framework.name;

//	NSString *groupName = tokenMO.parentNode.kName;  //TODO: Figure out the right group name.
	NSString *groupName = inferredInfo.referenceSubject;  //TODO: Figure out the right group name.
	[tokenCluster addNamedObject:token toGroupWithName:groupName];

	return token;
}

@end
