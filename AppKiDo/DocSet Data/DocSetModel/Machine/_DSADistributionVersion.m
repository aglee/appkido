// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DSADistributionVersion.m instead.

#import "_DSADistributionVersion.h"

@implementation DSADistributionVersionID
@end

@implementation _DSADistributionVersion

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DistributionVersion" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DistributionVersion";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DistributionVersion" inManagedObjectContext:moc_];
}

- (DSADistributionVersionID*)objectID {
	return (DSADistributionVersionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"architectureFlagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"architectureFlags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic architectureFlags;

- (int32_t)architectureFlagsValue {
	NSNumber *result = [self architectureFlags];
	return [result intValue];
}

- (void)setArchitectureFlagsValue:(int32_t)value_ {
	[self setArchitectureFlags:@(value_)];
}

- (int32_t)primitiveArchitectureFlagsValue {
	NSNumber *result = [self primitiveArchitectureFlags];
	return [result intValue];
}

- (void)setPrimitiveArchitectureFlagsValue:(int32_t)value_ {
	[self setPrimitiveArchitectureFlags:@(value_)];
}

@dynamic distributionName;

@dynamic versionString;

@dynamic deprecatedInInverse;

- (NSMutableSet<TokenMetainformation*>*)deprecatedInInverseSet {
	[self willAccessValueForKey:@"deprecatedInInverse"];

	NSMutableSet<TokenMetainformation*> *result = (NSMutableSet<TokenMetainformation*>*)[self mutableSetValueForKey:@"deprecatedInInverse"];

	[self didAccessValueForKey:@"deprecatedInInverse"];
	return result;
}

@dynamic introducedInInverse;

- (NSMutableSet<TokenMetainformation*>*)introducedInInverseSet {
	[self willAccessValueForKey:@"introducedInInverse"];

	NSMutableSet<TokenMetainformation*> *result = (NSMutableSet<TokenMetainformation*>*)[self mutableSetValueForKey:@"introducedInInverse"];

	[self didAccessValueForKey:@"introducedInInverse"];
	return result;
}

@dynamic removedAfterInverse;

- (NSMutableSet<TokenMetainformation*>*)removedAfterInverseSet {
	[self willAccessValueForKey:@"removedAfterInverse"];

	NSMutableSet<TokenMetainformation*> *result = (NSMutableSet<TokenMetainformation*>*)[self mutableSetValueForKey:@"removedAfterInverse"];

	[self didAccessValueForKey:@"removedAfterInverse"];
	return result;
}

@end

@implementation DSADistributionVersionAttributes 
+ (NSString *)architectureFlags {
	return @"architectureFlags";
}
+ (NSString *)distributionName {
	return @"distributionName";
}
+ (NSString *)versionString {
	return @"versionString";
}
@end

@implementation DSADistributionVersionRelationships 
+ (NSString *)deprecatedInInverse {
	return @"deprecatedInInverse";
}
+ (NSString *)introducedInInverse {
	return @"introducedInInverse";
}
+ (NSString *)removedAfterInverse {
	return @"removedAfterInverse";
}
@end

