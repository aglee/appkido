// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TokenGroup.m instead.

#import "_TokenGroup.h"

@implementation TokenGroupID
@end

@implementation _TokenGroup

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TokenGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TokenGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TokenGroup" inManagedObjectContext:moc_];
}

- (TokenGroupID*)objectID {
	return (TokenGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic title;

@dynamic tokens;

- (NSMutableSet<DSAToken*>*)tokensSet {
	[self willAccessValueForKey:@"tokens"];

	NSMutableSet<DSAToken*> *result = (NSMutableSet<DSAToken*>*)[self mutableSetValueForKey:@"tokens"];

	[self didAccessValueForKey:@"tokens"];
	return result;
}

@end

@implementation TokenGroupAttributes 
+ (NSString *)title {
	return @"title";
}
@end

@implementation TokenGroupRelationships 
+ (NSString *)tokens {
	return @"tokens";
}
@end

