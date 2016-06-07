// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FilePath.m instead.

#import "_FilePath.h"

@implementation FilePathID
@end

@implementation _FilePath

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FilePath" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FilePath";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FilePath" inManagedObjectContext:moc_];
}

- (FilePathID*)objectID {
	return (FilePathID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic path;

@end

@implementation FilePathAttributes 
+ (NSString *)path {
	return @"path";
}
@end

