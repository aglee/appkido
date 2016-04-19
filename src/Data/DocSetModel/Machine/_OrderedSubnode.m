// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OrderedSubnode.m instead.

#import "_OrderedSubnode.h"

@implementation OrderedSubnodeID
@end

@implementation _OrderedSubnode

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OrderedSubnode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OrderedSubnode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OrderedSubnode" inManagedObjectContext:moc_];
}

- (OrderedSubnodeID*)objectID {
	return (OrderedSubnodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic order;

- (int16_t)orderValue {
	NSNumber *result = [self order];
	return [result shortValue];
}

- (void)setOrderValue:(int16_t)value_ {
	[self setOrder:@(value_)];
}

- (int16_t)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result shortValue];
}

- (void)setPrimitiveOrderValue:(int16_t)value_ {
	[self setPrimitiveOrder:@(value_)];
}

@dynamic node;

@dynamic parent;

@end

@implementation OrderedSubnodeAttributes 
+ (NSString *)order {
	return @"order";
}
@end

@implementation OrderedSubnodeRelationships 
+ (NSString *)node {
	return @"node";
}
+ (NSString *)parent {
	return @"parent";
}
@end

