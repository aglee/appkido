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


		(void)[self _maybeImportCToken:tokenMO];
	}
}

- (AKToken *)_maybeImportCToken:(DSAToken *)tokenMO
{
	NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
	if (frameworkName == nil) {
		//QLog(@"+++ Could not determine framework for token with name %@, type %@.", tokenMO.tokenName, tokenMO.tokenType.typeName);
		return nil;
	}

	AKFramework *framework = [self frameworkWithName:frameworkName];
	if (framework == nil) {
		QLog(@"+++ Could not import token with name %@, type %@ -- unaware of any framework named %@.", tokenMO.tokenName, tokenMO.tokenType.typeName, frameworkName);
		return nil;
	}

	AKToken *token = [framework maybeImportCToken:tokenMO];
	if (token == nil) {
		//QLog(@"+++ [ODD] Could not import token '%@' with type '%@'", tokenMO.tokenName, tokenMO.tokenType.typeName);
	} else {
		//QLog(@"+++ Framework %@ imported C token %@", framework.name, token);
	}
	return token;
}

@end
