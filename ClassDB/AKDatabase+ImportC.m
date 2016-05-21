//
//  AKDatabase+ObjectiveC.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"
#import "AKFramework.h"
#import "AKFunctionToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"

@implementation AKDatabase (PrivateC)

- (void)_importCTokens
{
	for (DSAToken *tokenMO in [self _arrayWithTokenMOsForLanguage:@"C"]) {
		//TODO: Figure out whether I really do want to ignore the "tag" token type.
		if ([tokenMO.tokenType.typeName isEqualToString:@"tag"]) {
			continue;
		}

		// Figure out what framework the token belongs to.
		AKFramework *framework = [self _frameworkForTokenMO:tokenMO];
		if (framework == nil) {
			continue;
		}

		// Create the AKToken and add it to the framework.
		AKToken *token = [self _maybeAddTokenWithTokenMO:tokenMO toFramework:framework];
		if (token == nil) {
			continue;
		}

		// Handle the case where the token seems to refer to a notification.
		[self _checkWhetherTokenIsNotification:token];
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
	[tokenCluster addNamedObject:token toGroupWithName:tokenCluster.name];  //TODO: Figure out the right group name.
	//QLog(@"+++ Framework %@ imported C token %@", framework.name, token);

	return token;
}

- (void)_checkWhetherTokenIsNotification:(AKToken *)token
{
	if (![token.name hasSuffix:@"Notification"]) {
		return;
	}

	//TODO: Fill this in.
}

@end
