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
	for (DSAToken *tokenMO in [self _arrayWithTokenMOsForLanguage:@"C"]) {
		// Special case: "tag" tokens.  As far as I can tell, they are redundant
		// with other tags, so I'm going to ignore them until I learn otherwise.
		if ([tokenMO.tokenType.typeName isEqualToString:@"tag"]) {
			continue;
		}

		// Infer some info about the token.
		AKTokenInferredInfo *inferredInfo = [[AKTokenInferredInfo alloc] initWithTokenMO:tokenMO database:self];
		if (inferredInfo.framework == nil) {
			NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
			inferredInfo.framework = [self frameworkWithName:frameworkName];
		}
		if (inferredInfo.framework == nil) {
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

	if (inferredInfo.behaviorToken) {
		// Attach the notification to its owning behavior.
		AKNotificationToken *notifToken = [[AKNotificationToken alloc] initWithTokenMO:inferredInfo.tokenMO];
		[inferredInfo.behaviorToken addNotification:notifToken];
		return notifToken;
	} else {
		// Non-behavior notifications get lumped with the framework's other constants.
		AKToken *notifToken = [[AKToken alloc] initWithTokenMO:inferredInfo.tokenMO];
		NSString *groupName = inferredInfo.referenceSubject;  //TODO: Figure out the right group name.
		[inferredInfo.framework.constantsCluster addNamedObject:notifToken
												toGroupWithName:groupName];
		return notifToken;
	}
}

- (AKToken *)_maybeAddFunctionTokenWithInferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	if (![inferredInfo.tokenMO.tokenType.typeName isEqualToString:@"func"]) {
		return nil;
	}

	AKToken *token = [[AKFunctionToken alloc] initWithTokenMO:inferredInfo.tokenMO];
	token.frameworkName = inferredInfo.framework.name;

	NSString *groupName = inferredInfo.tokenMO.parentNode.kName;  //TODO: Figure out the right group name.
	[inferredInfo.framework.functionsCluster addNamedObject:token toGroupWithName:groupName];

	return token;
}

- (AKToken *)_maybeAddTokenToBehaviorWithInferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	if (inferredInfo.behaviorToken == nil) {
		return nil;
	}

	AKToken *token = [[AKToken alloc] initWithTokenMO:inferredInfo.tokenMO];
	token.frameworkName = inferredInfo.framework.name;

	NSString *tokenType = inferredInfo.tokenMO.tokenType.typeName;
	if ([tokenType isEqualToString:@"data"]
		|| [tokenType isEqualToString:@"econst"]
		|| [tokenType isEqualToString:@"macro"]) {

		[inferredInfo.behaviorToken addConstantToken:token];
		//QLog(@"+++ Added constant %@ to %@.", token.name, inferredInfo.behaviorToken);
	} else if ([tokenType isEqualToString:@"tdef"]) {
		[inferredInfo.behaviorToken addDataTypeToken:token];
		//QLog(@"+++ Added data type %@ to %@.", token, inferredInfo.behaviorToken);
	} else {
		//QLog(@"+++ [ODD] %s Unexpected token type %@ for %@.", tokenType, token);
		return nil;
	}

	return token;
}

- (AKToken *)_maybeAddTokenToFrameworkWithInferredInfo:(AKTokenInferredInfo *)inferredInfo
{
	// Figure out which token cluster within the framework the token belongs to.
	NSDictionary *clustersByType = @{
									 @"data" : inferredInfo.framework.constantsCluster,
									 @"econst" : inferredInfo.framework.enumsCluster,
									 @"macro" : inferredInfo.framework.macrosCluster,
									 @"tdef" : inferredInfo.framework.dataTypesCluster,
									 };
	AKNamedObjectCluster *tokenCluster = clustersByType[inferredInfo.tokenMO.tokenType.typeName];
	if (tokenCluster == nil) {
		QLog(@"+++ Could not import token %@ -- framework %@ has no token bin for type %@.", inferredInfo.tokenMO.tokenName, inferredInfo.framework.name, inferredInfo.tokenMO.tokenType.typeName);
		return nil;
	}

	// Create the token and add it to the framework.
	AKToken *token = [[AKToken alloc] initWithTokenMO:inferredInfo.tokenMO];
	token.frameworkName = inferredInfo.framework.name;

	NSString *groupName = inferredInfo.referenceSubject;  //TODO: Figure out the right group name.
	[tokenCluster addNamedObject:token toGroupWithName:groupName];

	return token;
}

@end
