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
#import "AKBehaviorInfo.h"
#import "DIGSLog.h"

@implementation AKDatabase (ImportC)

- (void)_importCTokens
{
	for (DSAToken *tokenMO in [self _fetchTokenMOsWithLanguage:@"C" tokenType:nil]) {
		// As far as I can tell, tokens whose tokenType is "tag" are redundant
		// with other tags, so I'm going to ignore them until I learn otherwise.
		NSString *tokenType = tokenMO.tokenType.typeName;
		if ([tokenType isEqualToString:@"tag"]) {
			//QLog(@"+++ Skipping tokenMO with type 'tag', path '%@', anchor '%@'.", tokenMO.metainformation.file.path, tokenMO.metainformation.anchor);
			continue;
		}

		// What framework does this token belong to?
		AKFramework *framework = [self _frameworkForTokenMO:tokenMO];
		if (framework == nil) {
			QLog(@"+++ [ERROR] Could not infer framework name for tokenMO '%@', type '%@'.", tokenMO.tokenName, tokenType);
			continue;
		}

		// Is this token a "pseudo-member" of a behavior?
		AKToken *token = [self _maybeAddPseudoMemberWithTokenMO:tokenMO];

		// If not, add it to the framework.
		if (token == nil) {
			NSString *groupName = tokenMO.parentNode.kName;
			NSString *suffixToTrim = @" Reference";
			if ([groupName hasSuffix:suffixToTrim]) {
				groupName = [groupName substringToIndex:(groupName.length - suffixToTrim.length)];
			}

			if ([tokenType isEqualToString:@"func"]) {
				token = [[AKFunctionToken alloc] initWithTokenMO:tokenMO];
//				groupName = @"FUNCTIONS";
			} else {
				token = [[AKToken alloc] initWithTokenMO:tokenMO];
//				groupName = @"GLOBALS";
			}
			[framework.functionsAndGlobalsCluster addNamedObject:token toGroupWithName:groupName];
		}

//		// Figure out which token cluster within the framework the token belongs to.
//		NSArray *tokenTypes = @[@"data", @"econst", @"macro", @"tdef"];
//		if (![tokenTypes containsObject:tokenType]) {
//			QLog(@"+++ Could not import token %@ -- framework %@ has no token bin for type %@.", tokenMO.tokenName, framework.name, tokenType);
//			return nil;
//		}

		// Note the token's owning framework.
		token.frameworkName = framework.name;
	}
}

- (AKToken *)_maybeAddPseudoMemberWithTokenMO:(DSAToken *)tokenMO
{
	// Figure out what behavior, if any, owns this token.
	AKBehaviorInfo *owningBehaviorInfo = [self _behaviorInfoInferredFromTokenMO:tokenMO];
	if (owningBehaviorInfo == nil) {
		return nil;
	}
	AKBehaviorToken *owningBehaviorToken = [self _behaviorTokenWithInfo:owningBehaviorInfo];
	if (owningBehaviorToken == nil) {
		//QLog(@"+++ Could not derive behavior token from behaviorInfo %@.", owningBehaviorInfo);
		return nil;
	}

	// Is this token one of the behavior's "Notifications"?
	if ([tokenMO.tokenName hasSuffix:@"Notification"]) {
		AKNotificationToken *notifToken = [[AKNotificationToken alloc] initWithTokenMO:tokenMO];
		[owningBehaviorToken addNotification:notifToken];
		return notifToken;
	}

	// Is this token one of the behavior's "Constants"?
	NSString *tokenType = tokenMO.tokenType.typeName;
	if ([tokenType isEqualToString:@"data"]
		|| [tokenType isEqualToString:@"econst"]
		|| [tokenType isEqualToString:@"macro"])
	{
		AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
		[owningBehaviorToken addConstantToken:token];
		//QLog(@"+++ Added constant %@ to %@.", token, owningBehaviorToken);
		return token;
	}

	// Is this token one of the behavior's "Data Types"?
	if ([tokenType isEqualToString:@"tdef"]) {
		AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
		[owningBehaviorToken addDataTypeToken:token];
		//QLog(@"+++ Added data type '%@' to %@.", token.name, owningBehaviorToken);
		return token;
	}

	QLog(@"+++ [ODD] %s Unexpected token type '%@' for tokenMO '%@' seemingly owned by behavior %@.", tokenType, tokenMO.tokenName, owningBehaviorToken);
	return nil;
}

- (AKBehaviorToken *)_behaviorTokenWithInfo:(AKBehaviorInfo *)behaviorInfo
{
	if (behaviorInfo.nameOfClass) {
		AKClassToken *classToken = [self classTokenWithName:behaviorInfo.nameOfClass];
		if (classToken == nil) {
			QLog(@"+++ [ODD] No class with name %@.", behaviorInfo.nameOfClass);
			return nil;
		}
		return classToken;
	} else if (behaviorInfo.nameOfProtocol) {
		AKProtocolToken *protocolToken = [self protocolTokenWithName:behaviorInfo.nameOfProtocol];
		if (protocolToken == nil) {
			QLog(@"+++ [ODD] No protocol with name %@.", behaviorInfo.nameOfProtocol);
			return nil;
		}
		return protocolToken;
	} else {
		return nil;
	}
}

@end
