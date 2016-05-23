//
// AKBehaviorToken.m
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorToken.h"
#import "DIGSLog.h"
#import "AKClassMethodToken.h"
#import "AKInstanceMethodToken.h"
#import "AKProtocolToken.h"
#import "AKPropertyToken.h"

@interface AKBehaviorToken ()
@property (copy) NSMutableDictionary *implementedProtocolsByName;
@property (copy) NSMutableDictionary *propertiesByName;
@property (copy) NSMutableDictionary *classMethodsByName;
@property (copy) NSMutableDictionary *instanceMethodsByName;
@end

@implementation AKBehaviorToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_implementedProtocolsByName = [[NSMutableDictionary alloc] init];
		_propertiesByName = [[NSMutableDictionary alloc] init];
		_classMethodsByName = [[NSMutableDictionary alloc] init];
		_instanceMethodsByName = [[NSMutableDictionary alloc] init];
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
	if (self.implementedProtocolsByName[protocolToken.name]) {
		DIGSLogDebug(@"trying to add protocol [%@] again to behavior [%@], will ignore",
					 protocolToken.name, self.name);
	} else {
		self.implementedProtocolsByName[protocolToken.name] = protocolToken;
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
	NSArray *myProtocolTokens = self.implementedProtocolsByName.allValues;
	NSMutableArray *result = [NSMutableArray arrayWithArray:myProtocolTokens];
	for (AKProtocolToken *protocolToken in myProtocolTokens) 	{
		if (protocolToken != self) {
			[result addObjectsFromArray:protocolToken.implementedProtocols];  //TODO: Could this lead to duplicates in the result list?
		}
	}
	return result;
}

- (NSArray *)instanceMethodTokens
{
	return self.instanceMethodsByName.allValues;
}

#pragma mark - Getters and setters -- properties

- (NSArray *)propertyTokens
{
	return self.propertiesByName.allValues;
}

- (AKPropertyToken *)propertyTokenWithName:(NSString *)propertyName
{
	return (AKPropertyToken *)self.propertiesByName[propertyName];
}

- (void)addPropertyToken:(AKPropertyToken *)propertyToken
{
	if (self.propertiesByName[propertyToken.name]) {
		DIGSLogDebug(@"trying to add property [%@] again to behavior [%@], will ignore",
					 propertyToken.name, self.name);
	} else {
		self.propertiesByName[propertyToken.name] = propertyToken;
		propertyToken.owningBehavior = self;
	}
}

#pragma mark - Getters and setters -- class methods

- (NSArray *)classMethodTokens
{
	return self.classMethodsByName.allValues;
}

- (AKClassMethodToken *)classMethodWithName:(NSString *)methodName
{
	return (AKClassMethodToken *)self.classMethodsByName[methodName];
}

- (void)addClassMethod:(AKClassMethodToken *)methodToken
{
	if (self.classMethodsByName[methodToken.name]) {
		DIGSLogDebug(@"trying to add class method [%@] again to behavior [%@], will ignore",
					 methodToken.name, self.name);
	} else {
		self.classMethodsByName[methodToken.name] = methodToken;
		methodToken.owningBehavior = self;
	}
}

#pragma mark - Getters and setters -- instance methods

- (AKInstanceMethodToken *)instanceMethodWithName:(NSString *)methodName
{
	return (AKInstanceMethodToken *)self.instanceMethodsByName[methodName];
}

- (void)addInstanceMethod:(AKInstanceMethodToken *)methodToken
{
	if (self.instanceMethodsByName[methodToken.name]) {
		DIGSLogDebug(@"trying to add instance method [%@] again to behavior [%@], will ignore",
					 methodToken.name, self.name);
	} else {
		self.instanceMethodsByName[methodToken.name] = methodToken;
		methodToken.owningBehavior = self;
	}
}

@end
