// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DSAToken.m instead.

#import "_DSAToken.h"

@implementation DSATokenID
@end

@implementation _DSAToken

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Token" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Token";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Token" inManagedObjectContext:moc_];
}

- (DSATokenID*)objectID {
	return (DSATokenID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"alphaSortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"alphaSortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"firstLowercaseUTF8ByteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"firstLowercaseUTF8Byte"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic alphaSortOrder;

- (int32_t)alphaSortOrderValue {
	NSNumber *result = [self alphaSortOrder];
	return [result intValue];
}

- (void)setAlphaSortOrderValue:(int32_t)value_ {
	[self setAlphaSortOrder:@(value_)];
}

- (int32_t)primitiveAlphaSortOrderValue {
	NSNumber *result = [self primitiveAlphaSortOrder];
	return [result intValue];
}

- (void)setPrimitiveAlphaSortOrderValue:(int32_t)value_ {
	[self setPrimitiveAlphaSortOrder:@(value_)];
}

@dynamic firstLowercaseUTF8Byte;

- (int16_t)firstLowercaseUTF8ByteValue {
	NSNumber *result = [self firstLowercaseUTF8Byte];
	return [result shortValue];
}

- (void)setFirstLowercaseUTF8ByteValue:(int16_t)value_ {
	[self setFirstLowercaseUTF8Byte:@(value_)];
}

- (int16_t)primitiveFirstLowercaseUTF8ByteValue {
	NSNumber *result = [self primitiveFirstLowercaseUTF8Byte];
	return [result shortValue];
}

- (void)setPrimitiveFirstLowercaseUTF8ByteValue:(int16_t)value_ {
	[self setPrimitiveFirstLowercaseUTF8Byte:@(value_)];
}

@dynamic tokenName;

@dynamic tokenUSR;

@dynamic container;

@dynamic language;

@dynamic metainformation;

@dynamic parentNode;

@dynamic protocolContainers;

- (NSMutableSet<Container*>*)protocolContainersSet {
	[self willAccessValueForKey:@"protocolContainers"];

	NSMutableSet<Container*> *result = (NSMutableSet<Container*>*)[self mutableSetValueForKey:@"protocolContainers"];

	[self didAccessValueForKey:@"protocolContainers"];
	return result;
}

@dynamic relatedGroups;

- (NSMutableSet<TokenGroup*>*)relatedGroupsSet {
	[self willAccessValueForKey:@"relatedGroups"];

	NSMutableSet<TokenGroup*> *result = (NSMutableSet<TokenGroup*>*)[self mutableSetValueForKey:@"relatedGroups"];

	[self didAccessValueForKey:@"relatedGroups"];
	return result;
}

@dynamic relatedTokensInverse;

- (NSMutableSet<TokenMetainformation*>*)relatedTokensInverseSet {
	[self willAccessValueForKey:@"relatedTokensInverse"];

	NSMutableSet<TokenMetainformation*> *result = (NSMutableSet<TokenMetainformation*>*)[self mutableSetValueForKey:@"relatedTokensInverse"];

	[self didAccessValueForKey:@"relatedTokensInverse"];
	return result;
}

@dynamic superclassContainers;

- (NSMutableSet<Container*>*)superclassContainersSet {
	[self willAccessValueForKey:@"superclassContainers"];

	NSMutableSet<Container*> *result = (NSMutableSet<Container*>*)[self mutableSetValueForKey:@"superclassContainers"];

	[self didAccessValueForKey:@"superclassContainers"];
	return result;
}

@dynamic tokenType;

@end

@implementation DSATokenAttributes 
+ (NSString *)alphaSortOrder {
	return @"alphaSortOrder";
}
+ (NSString *)firstLowercaseUTF8Byte {
	return @"firstLowercaseUTF8Byte";
}
+ (NSString *)tokenName {
	return @"tokenName";
}
+ (NSString *)tokenUSR {
	return @"tokenUSR";
}
@end

@implementation DSATokenRelationships 
+ (NSString *)container {
	return @"container";
}
+ (NSString *)language {
	return @"language";
}
+ (NSString *)metainformation {
	return @"metainformation";
}
+ (NSString *)parentNode {
	return @"parentNode";
}
+ (NSString *)protocolContainers {
	return @"protocolContainers";
}
+ (NSString *)relatedGroups {
	return @"relatedGroups";
}
+ (NSString *)relatedTokensInverse {
	return @"relatedTokensInverse";
}
+ (NSString *)superclassContainers {
	return @"superclassContainers";
}
+ (NSString *)tokenType {
	return @"tokenType";
}
@end

