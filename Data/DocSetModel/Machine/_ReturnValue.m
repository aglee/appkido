// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ReturnValue.m instead.

#import "_ReturnValue.h"

@implementation ReturnValueID
@end

@implementation _ReturnValue

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ReturnValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ReturnValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ReturnValue" inManagedObjectContext:moc_];
}

- (ReturnValueID*)objectID {
	return (ReturnValueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic abstract;

@end

@implementation ReturnValueAttributes 
+ (NSString *)abstract {
	return @"abstract";
}
@end

