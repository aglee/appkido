//
//  AKDatabase+ObjectiveC.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"
#import "AKClassToken.h"
#import "AKFramework.h"
#import "AKFunctionToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKNodeNameInferredInfo.h"
#import "AKNotificationToken.h"
#import "AKProtocolToken.h"
#import "DIGSLog.h"

@implementation AKDatabase (PrivateC)

- (void)_importCTokens
{
	for (DSAToken *tokenMO in [self _arrayWithTokenMOsForLanguage:@"C"]) {
		// Special case: "tag" tokens.  As far as I can tell, they are redundant
		// with other tags, so I'm going to ignore them until I learn otherwise.
		if ([tokenMO.tokenType.typeName isEqualToString:@"tag"]) {
			continue;
		}

		// Special case: notifications.  Handle them separately.
		AKToken *token = [self _maybeAddNotificationWithTokenMO:tokenMO];
		if (token) {
			continue;
		}

		// Figure out what framework the token belongs to.
		AKFramework *framework = [self _frameworkForTokenMO:tokenMO];
		if (framework == nil) {
			continue;
		}

		// Create the AKToken and try to add it to the framework.
		token = [self _maybeAddTokenWithTokenMO:tokenMO toFramework:framework];
		if (token == nil) {
			continue;
		}
	}
}

- (AKToken *)_maybeAddNotificationWithTokenMO:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenName hasSuffix:@"Notification"]) {
		return nil;
	}

	// Try to figure out what behavior to attach the notification to.
	NSString *parentNodeName = tokenMO.parentNode.kName;
	AKNodeNameInferredInfo *inferredInfo = [[AKNodeNameInferredInfo alloc] initWithNodeName:parentNodeName database:self];

	if (inferredInfo.behaviorToken) {
		// Attach the notification to its owning behavior.
		AKNotificationToken *notifToken = [[AKNotificationToken alloc] initWithTokenMO:tokenMO];
		[inferredInfo.behaviorToken addNotification:notifToken];
		return notifToken;
	} else {
		// Non-behavior notifications get lumped with the framework's other constants.
		AKToken *notifToken = [[AKToken alloc] initWithTokenMO:tokenMO];
		NSString *groupName = tokenMO.parentNode.kName;  //TODO: Figure out the right group name.
		[inferredInfo.framework.constantsCluster addNamedObject:notifToken
												toGroupWithName:groupName];
		return notifToken;
	}
}

- (AKFramework *)_frameworkForTokenMO:(DSAToken *)tokenMO
{
	// Figure out the name of the framework the token belongs to.
	NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
	if (frameworkName == nil) {
		//QLog(@"+++ Could not determine framework for token with name %@, type %@.", tokenMO.tokenName, tokenMO.tokenType.typeName);
		return nil;
	}

	// Get the AKFramework with that name.
	AKFramework *framework = [self frameworkWithName:frameworkName];
	if (framework == nil) {
		QLog(@"+++ Could not import token %@, type %@ -- unaware of any framework named %@.", tokenMO.tokenName, tokenMO.tokenType.typeName, frameworkName);
		return nil;
	}

	return framework;
}

- (AKToken *)_maybeAddTokenWithTokenMO:(DSAToken *)tokenMO toFramework:(AKFramework *)framework
{
	// Figure out which token cluster within the framework the token belongs to.
	AKNamedObjectCluster *tokenCluster = [framework tokenClusterWithTokenType:tokenMO.tokenType.typeName];
	if (tokenCluster == nil) {
		QLog(@"+++ Could not import token %@ -- framework %@ has no token bin for type %@.", tokenMO.tokenName, framework.name, tokenMO.tokenType.typeName);
		return nil;
	}

	// Create the token and add it to the framework.
	AKToken *token = ([tokenMO.tokenType.typeName isEqualToString:@"func"]
					  ? [[AKFunctionToken alloc] initWithTokenMO:tokenMO]
					  : [[AKToken alloc] initWithTokenMO:tokenMO]);
	token.frameworkName = framework.name;

	NSString *groupName = tokenMO.parentNode.kName;  //TODO: Figure out the right group name.
	[tokenCluster addNamedObject:token toGroupWithName:groupName];
	//QLog(@"+++ Framework %@ imported C token %@", framework.name, token);

	return token;
}

@end
