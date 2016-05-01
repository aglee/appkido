// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TokenMetainformation.m instead.

#import "_TokenMetainformation.h"

@implementation TokenMetainformationID
@end

@implementation _TokenMetainformation

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TokenMetainformation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TokenMetainformation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TokenMetainformation" inManagedObjectContext:moc_];
}

- (TokenMetainformationID*)objectID {
	return (TokenMetainformationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic abstract;

@dynamic anchor;

@dynamic declaration;

@dynamic deprecationSummary;

@dynamic declaredIn;

@dynamic deprecatedInVersions;

- (NSMutableSet<DSADistributionVersion*>*)deprecatedInVersionsSet {
	[self willAccessValueForKey:@"deprecatedInVersions"];

	NSMutableSet<DSADistributionVersion*> *result = (NSMutableSet<DSADistributionVersion*>*)[self mutableSetValueForKey:@"deprecatedInVersions"];

	[self didAccessValueForKey:@"deprecatedInVersions"];
	return result;
}

@dynamic file;

@dynamic introducedInVersions;

- (NSMutableSet<DSADistributionVersion*>*)introducedInVersionsSet {
	[self willAccessValueForKey:@"introducedInVersions"];

	NSMutableSet<DSADistributionVersion*> *result = (NSMutableSet<DSADistributionVersion*>*)[self mutableSetValueForKey:@"introducedInVersions"];

	[self didAccessValueForKey:@"introducedInVersions"];
	return result;
}

@dynamic parameters;

- (NSMutableSet<Parameter*>*)parametersSet {
	[self willAccessValueForKey:@"parameters"];

	NSMutableSet<Parameter*> *result = (NSMutableSet<Parameter*>*)[self mutableSetValueForKey:@"parameters"];

	[self didAccessValueForKey:@"parameters"];
	return result;
}

@dynamic relatedDocuments;

- (NSMutableSet<DSANode*>*)relatedDocumentsSet {
	[self willAccessValueForKey:@"relatedDocuments"];

	NSMutableSet<DSANode*> *result = (NSMutableSet<DSANode*>*)[self mutableSetValueForKey:@"relatedDocuments"];

	[self didAccessValueForKey:@"relatedDocuments"];
	return result;
}

@dynamic relatedSampleCode;

- (NSMutableSet<DSANode*>*)relatedSampleCodeSet {
	[self willAccessValueForKey:@"relatedSampleCode"];

	NSMutableSet<DSANode*> *result = (NSMutableSet<DSANode*>*)[self mutableSetValueForKey:@"relatedSampleCode"];

	[self didAccessValueForKey:@"relatedSampleCode"];
	return result;
}

@dynamic relatedTokens;

- (NSMutableSet<DSAToken*>*)relatedTokensSet {
	[self willAccessValueForKey:@"relatedTokens"];

	NSMutableSet<DSAToken*> *result = (NSMutableSet<DSAToken*>*)[self mutableSetValueForKey:@"relatedTokens"];

	[self didAccessValueForKey:@"relatedTokens"];
	return result;
}

@dynamic removedAfterVersions;

- (NSMutableSet<DSADistributionVersion*>*)removedAfterVersionsSet {
	[self willAccessValueForKey:@"removedAfterVersions"];

	NSMutableSet<DSADistributionVersion*> *result = (NSMutableSet<DSADistributionVersion*>*)[self mutableSetValueForKey:@"removedAfterVersions"];

	[self didAccessValueForKey:@"removedAfterVersions"];
	return result;
}

@dynamic returnValue;

@dynamic token;

@end

@implementation TokenMetainformationAttributes 
+ (NSString *)abstract {
	return @"abstract";
}
+ (NSString *)anchor {
	return @"anchor";
}
+ (NSString *)declaration {
	return @"declaration";
}
+ (NSString *)deprecationSummary {
	return @"deprecationSummary";
}
@end

@implementation TokenMetainformationRelationships 
+ (NSString *)declaredIn {
	return @"declaredIn";
}
+ (NSString *)deprecatedInVersions {
	return @"deprecatedInVersions";
}
+ (NSString *)file {
	return @"file";
}
+ (NSString *)introducedInVersions {
	return @"introducedInVersions";
}
+ (NSString *)parameters {
	return @"parameters";
}
+ (NSString *)relatedDocuments {
	return @"relatedDocuments";
}
+ (NSString *)relatedSampleCode {
	return @"relatedSampleCode";
}
+ (NSString *)relatedTokens {
	return @"relatedTokens";
}
+ (NSString *)removedAfterVersions {
	return @"removedAfterVersions";
}
+ (NSString *)returnValue {
	return @"returnValue";
}
+ (NSString *)token {
	return @"token";
}
@end

