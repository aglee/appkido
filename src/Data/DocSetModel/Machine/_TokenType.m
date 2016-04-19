// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TokenType.m instead.

#import "_TokenType.h"

@implementation TokenTypeID
@end

@implementation _TokenType

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TokenType" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TokenType";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TokenType" inManagedObjectContext:moc_];
}

- (TokenTypeID*)objectID {
	return (TokenTypeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic typeName;

@end

@implementation TokenTypeAttributes 
+ (NSString *)typeName {
	return @"typeName";
}
@end

