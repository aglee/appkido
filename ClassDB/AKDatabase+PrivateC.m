//
//  AKDatabase+ObjectiveC.m
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"

@implementation AKDatabase (PrivateC)

- (void)_importCTokens
{
	for (DSAToken *token in [self _arrayWithTokenMOsForLanguage:@"C"]) {
		if (![self _maybeImportCToken:token]) {
			QLog(@"+++ %s [ODD] Could not import token with type '%@'", __PRETTY_FUNCTION__, token.tokenType.typeName);
		}
	}
}

- (BOOL)_maybeImportCToken:(DSAToken *)token
{
	return ([self _maybeImportDataToken:token]
			|| [self _maybeImportEnumToken:token]
			|| [self _maybeImportFunctionToken:token]
			|| [self _maybeImportMacroToken:token]
			|| [self _maybeImportStructToken:token]
			|| [self _maybeImportTypedefToken:token]);
}

- (BOOL)_maybeImportDataToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"data"]) {
		return NO;
	}

	return YES;
}

- (BOOL)_maybeImportEnumToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"econst"]) {
		return NO;
	}

	return YES;
}

- (BOOL)_maybeImportFunctionToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"func"]) {
		return NO;
	}

	return YES;
}

- (BOOL)_maybeImportMacroToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"macro"]) {
		return NO;
	}

	return YES;
}

- (BOOL)_maybeImportStructToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"tag"]) {
		return NO;
	}

	return YES;
}

- (BOOL)_maybeImportTypedefToken:(DSAToken *)token
{
	if (![token.tokenType.typeName isEqualToString:@"tdef"]) {
		return NO;
	}

	return YES;
}

@end
