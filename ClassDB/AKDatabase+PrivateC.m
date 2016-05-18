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
		if (![self _maybeImportCToken:tokenMO]) {
			QLog(@"+++ %s [ODD] Could not import token '%@' with type '%@'", __PRETTY_FUNCTION__, tokenMO.tokenName, tokenMO.tokenType.typeName);
		}
	}
}

- (BOOL)_maybeImportCToken:(DSAToken *)tokenMO
{
	return ([self _maybeImportDataToken:tokenMO]
			|| [self _maybeImportEnumToken:tokenMO]
			|| [self _maybeImportFunctionToken:tokenMO]
			|| [self _maybeImportMacroToken:tokenMO]
			|| [self _maybeImportTagToken:tokenMO]
			|| [self _maybeImportTypedefToken:tokenMO]);
}

- (BOOL)_maybeImportDataToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"data"]) {
		return NO;
	}
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	[self.constantsCluster addNamedObject:token toGroupWithName:@"Constants"];
	return YES;
}

- (BOOL)_maybeImportEnumToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"econst"]) {
		return NO;
	}
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	[self.enumsCluster addNamedObject:token toGroupWithName:@"Enums"];
	return YES;
}

- (BOOL)_maybeImportFunctionToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"func"]) {
		return NO;
	}
	AKToken *token = [[AKFunctionToken alloc] initWithTokenMO:tokenMO];
	[self.functionsCluster addNamedObject:token toGroupWithName:@"Functions"];
	return YES;
}

- (BOOL)_maybeImportMacroToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"macro"]) {
		return NO;
	}
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	[self.macrosCluster addNamedObject:token toGroupWithName:@"Macros"];
	return YES;
}

- (BOOL)_maybeImportTagToken:(DSAToken *)tokenMO
{
	//TODO: I'm not sure yet what the token type "tag" means.  Current hypothesis is that I can ignore it.
	if (![tokenMO.tokenType.typeName isEqualToString:@"tag"]) {
		return NO;
	}

	return YES;
}

- (BOOL)_maybeImportTypedefToken:(DSAToken *)tokenMO
{
	if (![tokenMO.tokenType.typeName isEqualToString:@"tdef"]) {
		return NO;
	}
	AKToken *token = [[AKToken alloc] initWithTokenMO:tokenMO];
	[self.typedefsCluster addNamedObject:token toGroupWithName:@"Typedefs"];
	return YES;
}

@end
