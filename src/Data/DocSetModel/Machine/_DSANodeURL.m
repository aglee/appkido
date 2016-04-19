// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DSANodeURL.m instead.

#import "_DSANodeURL.h"

@implementation DSANodeURLID
@end

@implementation _DSANodeURL

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"NodeURL" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"NodeURL";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"NodeURL" inManagedObjectContext:moc_];
}

- (DSANodeURLID*)objectID {
	return (DSANodeURLID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"checksumValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"checksum"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic anchor;

@dynamic baseURL;

@dynamic checksum;

- (int32_t)checksumValue {
	NSNumber *result = [self checksum];
	return [result intValue];
}

- (void)setChecksumValue:(int32_t)value_ {
	[self setChecksum:@(value_)];
}

- (int32_t)primitiveChecksumValue {
	NSNumber *result = [self primitiveChecksum];
	return [result intValue];
}

- (void)setPrimitiveChecksumValue:(int32_t)value_ {
	[self setPrimitiveChecksum:@(value_)];
}

@dynamic fileName;

@dynamic path;

@dynamic node;

@end

@implementation DSANodeURLAttributes 
+ (NSString *)anchor {
	return @"anchor";
}
+ (NSString *)baseURL {
	return @"baseURL";
}
+ (NSString *)checksum {
	return @"checksum";
}
+ (NSString *)fileName {
	return @"fileName";
}
+ (NSString *)path {
	return @"path";
}
@end

@implementation DSANodeURLRelationships 
+ (NSString *)node {
	return @"node";
}
@end

