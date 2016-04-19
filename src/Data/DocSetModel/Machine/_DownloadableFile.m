// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DownloadableFile.m instead.

#import "_DownloadableFile.h"

@implementation DownloadableFileID
@end

@implementation _DownloadableFile

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DownloadableFile" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DownloadableFile";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DownloadableFile" inManagedObjectContext:moc_];
}

- (DownloadableFileID*)objectID {
	return (DownloadableFileID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic type;

- (int16_t)typeValue {
	NSNumber *result = [self type];
	return [result shortValue];
}

- (void)setTypeValue:(int16_t)value_ {
	[self setType:@(value_)];
}

@dynamic url;

@dynamic node;

@end

@implementation DownloadableFileAttributes 
+ (NSString *)type {
	return @"type";
}
+ (NSString *)url {
	return @"url";
}
@end

@implementation DownloadableFileRelationships 
+ (NSString *)node {
	return @"node";
}
@end

