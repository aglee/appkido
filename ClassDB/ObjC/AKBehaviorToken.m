//
// AKBehaviorToken.m
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorToken.h"
#import "DIGSLog.h"
#import "AKProtocolToken.h"
#import "AKPropertyToken.h"
#import "AKMethodToken.h"
#import "AKCollectionOfItems.h"

@implementation AKBehaviorToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithToken:(DSAToken *)token
{
	self = [super initWithToken:token];
	if (self) {
		_protocolTokens = [[NSMutableArray alloc] init];
		_protocolTokenNames = [[NSMutableSet alloc] init];

		_indexOfProperties = [[AKCollectionOfItems alloc] init];
		_indexOfClassMethods = [[AKCollectionOfItems alloc] init];
		_indexOfInstanceMethods = [[AKCollectionOfItems alloc] init];
	}
	return self;
}

#pragma mark - Getters and setters -- general

- (BOOL)isClassToken
{
	return NO;
}

- (void)addImplementedProtocol:(AKProtocolToken *)protocolToken
{
	if ([_protocolTokenNames containsObject:protocolToken.tokenName]) {
		// I've seen this happen when a .h contains two declarations of a
		// protocol in different #if branches. Example: NSURL.
		DIGSLogDebug(@"trying to add protocol [%@] again to behavior [%@]",
					 [protocolToken tokenName], [self tokenName]);
	} else {
		[_protocolTokens addObject:protocolToken];
		[_protocolTokenNames addObject:protocolToken.tokenName];
	}
}

- (void)addImplementedProtocols:(NSArray *)protocolTokens
{
	for (AKProtocolToken *protocolToken in protocolTokens) {
		[self addImplementedProtocol:protocolToken];
	}
}

- (NSArray *)implementedProtocols
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:_protocolTokens];
	for (AKProtocolToken *protocolToken in _protocolTokens) 	{
		if (protocolToken != self) {
			[result addObjectsFromArray:[protocolToken implementedProtocols]];
		}
	}
	return result;
}

- (NSArray *)instanceMethodTokens
{
	return [_indexOfInstanceMethods allItems];
}

#pragma mark - Getters and setters -- properties

- (NSArray *)propertyTokens
{
	return [_indexOfProperties allItems];
}

- (AKPropertyToken *)propertyTokenWithName:(NSString *)propertyName
{
	return (AKPropertyToken *)[_indexOfProperties itemWithTokenName:propertyName];
}

- (void)addPropertyToken:(AKPropertyToken *)propertyToken
{
	[_indexOfProperties addToken:propertyToken];
}

#pragma mark - Getters and setters -- class methods

- (NSArray *)classMethodTokens
{
	return [_indexOfClassMethods allItems];
}

- (AKMethodToken *)classMethodWithName:(NSString *)methodName
{
	return (AKMethodToken *)[_indexOfClassMethods itemWithTokenName:methodName];
}

- (void)addClassMethod:(AKMethodToken *)methodToken
{
	[_indexOfClassMethods addToken:methodToken];
}

#pragma mark - Getters and setters -- instance methods

- (AKMethodToken *)instanceMethodWithName:(NSString *)methodName
{
	return (AKMethodToken *)[_indexOfInstanceMethods itemWithTokenName:methodName];
}

- (void)addInstanceMethod:(AKMethodToken *)methodToken
{
	[_indexOfInstanceMethods addToken:methodToken];
}

#pragma mark - Getters and setters -- deprecated methods

- (AKMethodToken *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
										frameworkName:(NSString *)frameworkName
{
	// Is this an instance method or a class method?  Note this assumes a
	// a method item for the method already exists, presumably because we
	// parsed the header files.
	AKMethodToken *methodToken = [self classMethodWithName:methodName];

	if (methodToken == nil) {
		methodToken = [self instanceMethodWithName:methodName];
	}

	if (methodToken == nil) {
		DIGSLogInfo(@"Couldn't find class method or instance method named %@"
					@" while processing deprecated methods for behavior %@",
					methodName, [self tokenName]);
	} else {
		[methodToken setIsDeprecated:YES];
	}
	
	return methodToken;
}

@end
