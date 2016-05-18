//
//  AKDatabase+ObjectiveC.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"
#import "AKFunctionToken.h"
#import "AKNamedObjectCluster.h"

@implementation AKDatabase (PrivateC)

- (void)_importCTokens
{
	for (DSAToken *tokenMO in [self _arrayWithTokenMOsForLanguage:@"C"]) {
		AKToken *token = [self _maybeImportCToken:tokenMO];
		if (token) {
			token.frameworkName = [self _frameworkNameForTokenMO:tokenMO];
//		} else {
		} else if (![tokenMO.tokenType.typeName isEqualToString:@"tag"]) {  //TODO: Figure out whether I really do want to ignore the "tag" token type.
			QLog(@"+++ %s [ODD] Could not import token '%@' with type '%@'", __PRETTY_FUNCTION__, tokenMO.tokenName, tokenMO.tokenType.typeName);
		}
	}
}

- (AKToken *)_maybeImportCToken:(DSAToken *)tokenMO
{
	return ([self _maybeImportDataToken:tokenMO]
			?: [self _maybeImportEnumToken:tokenMO]
			?: [self _maybeImportFunctionToken:tokenMO]
			?: [self _maybeImportMacroToken:tokenMO]
			?: [self _maybeImportTagToken:tokenMO]
			?: [self _maybeImportTypedefToken:tokenMO]);
}

- (AKToken *)_maybeImportDataToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"data"]) {
		return nil;
	}
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	[self.constantsCluster addNamedObject:token toGroupWithName:@"Constants"];
	return token;
}

- (AKToken *)_maybeImportEnumToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"econst"]) {
		return nil;
	}
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	[self.enumsCluster addNamedObject:token toGroupWithName:@"Enums"];
	return token;
}

- (AKToken *)_maybeImportFunctionToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"func"]) {
		return nil;
	}
	AKToken *token = [[AKFunctionToken alloc] initWithTokenMO:tokenMO];
	[self.functionsCluster addNamedObject:token toGroupWithName:@"Functions"];
	return token;
}

- (AKToken *)_maybeImportMacroToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"macro"]) {
		return nil;
	}
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	[self.macrosCluster addNamedObject:token toGroupWithName:@"Macros"];
	return token;
}

- (AKToken *)_maybeImportTagToken:(DSAToken *)tokenMO
{
	//TODO: I'm not sure yet what the token type "tag" means.  Current hypothesis is that I can ignore it.
	if (![tokenMO.tokenType.typeName isEqualToString:@"tag"]) {
		return nil;
	}

	return nil;
}

- (AKToken *)_maybeImportTypedefToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"tdef"]) {
		return nil;
	}
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	[self.typedefsCluster addNamedObject:token toGroupWithName:@"Typedefs"];
	return token;
}

@end
