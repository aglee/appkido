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
#import "AKNotificationToken.h"
#import "AKProtocolToken.h"
#import "AKPropertyToken.h"

@interface AKBehaviorToken ()
@property (copy) NSMutableDictionary *adoptedProtocolTokensByName;
@property (copy) NSMutableDictionary *propertiesByName;
@property (copy) NSMutableDictionary *classMethodsByName;
@property (copy) NSMutableDictionary *instanceMethodsByName;
@property (copy) NSMutableDictionary *dataTypeTokensByName;
@property (copy) NSMutableDictionary *constantTokensByName;
@property (copy) NSMutableDictionary *notificationsByName;
@end

@implementation AKBehaviorToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_adoptedProtocolTokensByName = [[NSMutableDictionary alloc] init];
		_propertiesByName = [[NSMutableDictionary alloc] init];
		_classMethodsByName = [[NSMutableDictionary alloc] init];
		_instanceMethodsByName = [[NSMutableDictionary alloc] init];
		_dataTypeTokensByName = [[NSMutableDictionary alloc] init];
		_constantTokensByName = [[NSMutableDictionary alloc] init];
		_notificationsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark - Getters and setters

- (BOOL)isClassToken
{
	return NO;
}

- (NSArray *)adoptedProtocolTokens
{
	NSArray *myProtocolTokens = self.adoptedProtocolTokensByName.allValues;
	NSMutableArray *result = [NSMutableArray arrayWithArray:myProtocolTokens];
	for (AKProtocolToken *protocolToken in myProtocolTokens) 	{
		if (protocolToken != self) {
			[result addObjectsFromArray:protocolToken.adoptedProtocolTokens];  //TODO: Could this lead to duplicates in the result list?
		}
	}
	return result;
}

- (NSArray *)propertyTokens
{
	return self.propertiesByName.allValues;
}

- (NSArray *)classMethodTokens
{
	return self.classMethodsByName.allValues;
}

- (NSArray *)instanceMethodTokens
{
	return self.instanceMethodsByName.allValues;
}

- (NSArray *)dataTypeTokens
{
	return self.dataTypeTokensByName.allValues;
}

- (NSArray *)constantTokens
{
	return self.constantTokensByName.allValues;
}

- (BOOL)hasContent
{
	// The token is empty if it has no header, no doc path, and no members.
	return (self.hasHeader
			|| self.tokenMO.metainformation.file.path != nil
			|| self.adoptedProtocolTokensByName.count > 0
			|| self.propertiesByName.count > 0
			|| self.classMethodsByName.count > 0
			|| self.instanceMethodsByName.count > 0
			|| self.dataTypeTokensByName.count > 0
			|| self.constantTokensByName.count > 0
			|| self.notificationsByName.count > 0);
}

#pragma mark - Adopted protocol tokens

- (void)addAdoptedProtocol:(AKProtocolToken *)protocolToken
{
	if (self.adoptedProtocolTokensByName[protocolToken.name]) {
		DIGSLogDebug(@"trying to add protocol [%@] again to behavior [%@], will ignore",
					 protocolToken.name, self.name);
	} else {
		self.adoptedProtocolTokensByName[protocolToken.name] = protocolToken;
	}
}

#pragma mark - Property tokens

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

#pragma mark - Method tokens

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

#pragma mark - Data types tokens

- (void)addDataTypeToken:(AKToken *)token
{
	self.dataTypeTokensByName[token.name] = token;
}

- (AKToken *)dataTypeTokenWithName:(NSString *)name
{
	return self.dataTypeTokensByName[name];
}

#pragma mark - Constants tokens

- (void)addConstantToken:(AKToken *)token
{
	self.constantTokensByName[token.name] = token;
}

- (AKToken *)constantTokenWithName:(NSString *)name
{
	return self.constantTokensByName[name];
}

#pragma mark - Notification tokens

- (NSArray *)notificationTokens
{
	return self.notificationsByName.allValues;
}

- (AKNotificationToken *)notificationWithName:(NSString *)notificationName
{
	return (AKNotificationToken *)self.notificationsByName[notificationName];
}

- (void)addNotification:(AKNotificationToken *)notificationToken
{
	self.notificationsByName[notificationToken.name] = notificationToken;
	notificationToken.owningBehavior = self;
}

#pragma mark - Tear-down

- (void)tearDown
{
	[self.adoptedProtocolTokensByName removeAllObjects];
	[self.propertiesByName removeAllObjects];
	[self.classMethodsByName removeAllObjects];
	[self.instanceMethodsByName removeAllObjects];
	[self.dataTypeTokensByName removeAllObjects];
	[self.constantTokensByName removeAllObjects];
	[self.notificationsByName removeAllObjects];
}

@end
