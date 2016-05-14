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
#import "AKNamedCollection.h"

@interface AKBehaviorToken ()
@property (strong) AKNamedCollection *implementedProtocolsCollection;
@property (strong) AKNamedCollection *propertiesCollection;
@property (strong) AKNamedCollection *classMethodsCollection;
@property (strong) AKNamedCollection *instanceMethodsCollection;
@end

@implementation AKBehaviorToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	if (self) {
		_implementedProtocolsCollection = [[AKNamedCollection alloc] initWithName:@"Implemented Protocols"];
		_propertiesCollection = [[AKNamedCollection alloc] initWithName:@"Properties"];
		_classMethodsCollection = [[AKNamedCollection alloc] initWithName:@"Class Methods"];
		_instanceMethodsCollection = [[AKNamedCollection alloc] initWithName:@"Instance Methods"];
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
	if ([self.implementedProtocolsCollection addElementIfAbsent:protocolToken] != nil) {
		DIGSLogDebug(@"trying to add protocol [%@] again to behavior [%@]",
					 [protocolToken tokenName], [self tokenName]);
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
	NSArray *myProtocolTokens = self.implementedProtocolsCollection.elements;
	NSMutableArray *result = [NSMutableArray arrayWithArray:myProtocolTokens];
	for (AKProtocolToken *protocolToken in myProtocolTokens) 	{
		if (protocolToken != self) {
			[result addObjectsFromArray:[protocolToken implementedProtocols]];
		}
	}
	return result;
}

- (NSArray *)instanceMethodTokens
{
	return self.instanceMethodsCollection.elements;
}

#pragma mark - Getters and setters -- properties

- (NSArray *)propertyTokens
{
	return self.propertiesCollection.elements;
}

- (AKPropertyToken *)propertyTokenWithName:(NSString *)propertyName
{
	return (AKPropertyToken *)[self.propertiesCollection elementWithName:propertyName];
}

- (void)addPropertyToken:(AKPropertyToken *)propertyToken
{
	(void)[self.propertiesCollection addElementIfAbsent:propertyToken];
}

#pragma mark - Getters and setters -- class methods

- (NSArray *)classMethodTokens
{
	return self.classMethodsCollection.elements;
}

- (AKMethodToken *)classMethodWithName:(NSString *)methodName
{
	return (AKMethodToken *)[self.classMethodsCollection elementWithName:methodName];
}

- (void)addClassMethod:(AKMethodToken *)methodToken
{
	(void)[self.classMethodsCollection addElementIfAbsent:methodToken];
}

#pragma mark - Getters and setters -- instance methods

- (AKMethodToken *)instanceMethodWithName:(NSString *)methodName
{
	return (AKMethodToken *)[self.instanceMethodsCollection elementWithName:methodName];
}

- (void)addInstanceMethod:(AKMethodToken *)methodToken
{
	(void)[self.instanceMethodsCollection addElementIfAbsent:methodToken];
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
