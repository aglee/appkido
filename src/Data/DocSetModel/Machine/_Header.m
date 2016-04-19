// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Header.m instead.

#import "_Header.h"

@implementation HeaderID
@end

@implementation _Header

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Header" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Header";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Header" inManagedObjectContext:moc_];
}

- (HeaderID*)objectID {
	return (HeaderID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic frameworkName;

@dynamic headerPath;

@end

@implementation HeaderAttributes 
+ (NSString *)frameworkName {
	return @"frameworkName";
}
+ (NSString *)headerPath {
	return @"headerPath";
}
@end

