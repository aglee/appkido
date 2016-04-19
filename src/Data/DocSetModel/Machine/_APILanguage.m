// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to APILanguage.m instead.

#import "_APILanguage.h"

@implementation APILanguageID
@end

@implementation _APILanguage

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"APILanguage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"APILanguage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"APILanguage" inManagedObjectContext:moc_];
}

- (APILanguageID*)objectID {
	return (APILanguageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic fullName;

@dynamic nodes;

- (NSMutableSet<DSANode*>*)nodesSet {
	[self willAccessValueForKey:@"nodes"];

	NSMutableSet<DSANode*> *result = (NSMutableSet<DSANode*>*)[self mutableSetValueForKey:@"nodes"];

	[self didAccessValueForKey:@"nodes"];
	return result;
}

@end

@implementation APILanguageAttributes 
+ (NSString *)fullName {
	return @"fullName";
}
@end

@implementation APILanguageRelationships 
+ (NSString *)nodes {
	return @"nodes";
}
@end

