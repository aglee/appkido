// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Parameter.m instead.

#import "_Parameter.h"

@implementation ParameterID
@end

@implementation _Parameter

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Parameter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Parameter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Parameter" inManagedObjectContext:moc_];
}

- (ParameterID*)objectID {
	return (ParameterID*)[super objectID];
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

@dynamic abstract;

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

@dynamic parameterName;

@end

@implementation ParameterAttributes 
+ (NSString *)abstract {
	return @"abstract";
}
+ (NSString *)order {
	return @"order";
}
+ (NSString *)parameterName {
	return @"parameterName";
}
@end

