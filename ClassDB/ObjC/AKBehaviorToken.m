//
// AKBehaviorToken.m
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorToken.h"
#import "DIGSLog.h"
#import "AKProtocolToken.h"
#import "AKPropertyItem.h"
#import "AKMethodItem.h"
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

- (NSArray *)instanceMethodItems
{
	return [_indexOfInstanceMethods allItems];
}

#pragma mark - Getters and setters -- properties

- (NSArray *)propertyItems
{
	return [_indexOfProperties allItems];
}

- (AKPropertyItem *)propertyItemWithName:(NSString *)propertyName
{
	return (AKPropertyItem *)[_indexOfProperties itemWithTokenName:propertyName];
}

- (void)addPropertyItem:(AKPropertyItem *)propertyItem
{
	[_indexOfProperties addToken:propertyItem];
}

#pragma mark - Getters and setters -- class methods

- (NSArray *)classMethodItems
{
	return [_indexOfClassMethods allItems];
}

- (AKMethodItem *)classMethodWithName:(NSString *)methodName
{
	return (AKMethodItem *)[_indexOfClassMethods itemWithTokenName:methodName];
}

- (void)addClassMethod:(AKMethodItem *)methodItem
{
	[_indexOfClassMethods addToken:methodItem];
}

#pragma mark - Getters and setters -- instance methods

- (AKMethodItem *)instanceMethodWithName:(NSString *)methodName
{
	return (AKMethodItem *)[_indexOfInstanceMethods itemWithTokenName:methodName];
}

- (void)addInstanceMethod:(AKMethodItem *)methodItem
{
	[_indexOfInstanceMethods addToken:methodItem];
}

#pragma mark - Getters and setters -- deprecated methods

- (AKMethodItem *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
										frameworkName:(NSString *)frameworkName
{
	// Is this an instance method or a class method?  Note this assumes a
	// a method item for the method already exists, presumably because we
	// parsed the header files.
	AKMethodItem *methodItem = [self classMethodWithName:methodName];

	if (methodItem == nil) {
		methodItem = [self instanceMethodWithName:methodName];
	}

	if (methodItem == nil) {
		DIGSLogInfo(@"Couldn't find class method or instance method named %@"
					@" while processing deprecated methods for behavior %@",
					methodName, [self tokenName]);
	} else {
		[methodItem setIsDeprecated:YES];
	}
	
	return methodItem;
}

@end
