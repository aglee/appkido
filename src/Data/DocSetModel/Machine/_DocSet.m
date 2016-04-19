// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocSet.m instead.

#import "_DocSet.h"

@implementation DocSetID
@end

@implementation _DocSet

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DocSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DocSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DocSet" inManagedObjectContext:moc_];
}

- (DocSetID*)objectID {
	return (DocSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic configurationVersion;

@dynamic rootNode;

@end

@implementation DocSetAttributes 
+ (NSString *)configurationVersion {
	return @"configurationVersion";
}
@end

@implementation DocSetRelationships 
+ (NSString *)rootNode {
	return @"rootNode";
}
@end

@implementation DocSetUserInfo 
+ (NSString *)DocSetModelVersion {
	return @"14";
}
@end

