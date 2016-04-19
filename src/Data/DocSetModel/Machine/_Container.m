// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Container.m instead.

#import "_Container.h"

@implementation ContainerID
@end

@implementation _Container

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Container" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Container";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Container" inManagedObjectContext:moc_];
}

- (ContainerID*)objectID {
	return (ContainerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic containerName;

@dynamic adoptedBy;

- (NSMutableSet<DSAToken*>*)adoptedBySet {
	[self willAccessValueForKey:@"adoptedBy"];

	NSMutableSet<DSAToken*> *result = (NSMutableSet<DSAToken*>*)[self mutableSetValueForKey:@"adoptedBy"];

	[self didAccessValueForKey:@"adoptedBy"];
	return result;
}

@dynamic subclassedBy;

- (NSMutableSet<DSAToken*>*)subclassedBySet {
	[self willAccessValueForKey:@"subclassedBy"];

	NSMutableSet<DSAToken*> *result = (NSMutableSet<DSAToken*>*)[self mutableSetValueForKey:@"subclassedBy"];

	[self didAccessValueForKey:@"subclassedBy"];
	return result;
}

@end

@implementation ContainerAttributes 
+ (NSString *)containerName {
	return @"containerName";
}
@end

@implementation ContainerRelationships 
+ (NSString *)adoptedBy {
	return @"adoptedBy";
}
+ (NSString *)subclassedBy {
	return @"subclassedBy";
}
@end

