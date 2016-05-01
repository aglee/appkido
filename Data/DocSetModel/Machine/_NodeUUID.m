// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NodeUUID.m instead.

#import "_NodeUUID.h"

@implementation NodeUUIDID
@end

@implementation _NodeUUID

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"NodeUUID" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"NodeUUID";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"NodeUUID" inManagedObjectContext:moc_];
}

- (NodeUUIDID*)objectID {
	return (NodeUUIDID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic uuid;

@dynamic node;

@end

@implementation NodeUUIDAttributes 
+ (NSString *)uuid {
	return @"uuid";
}
@end

@implementation NodeUUIDRelationships 
+ (NSString *)node {
	return @"node";
}
@end

