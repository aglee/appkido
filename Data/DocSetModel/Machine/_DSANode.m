// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DSANode.m instead.

#import "_DSANode.h"

@implementation DSANodeID
@end

@implementation _DSANode

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Node";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Node" inManagedObjectContext:moc_];
}

- (DSANodeID*)objectID {
	return (DSANodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"installDomainValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"installDomain"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"kDocumentTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"kDocumentType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"kIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"kID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"kIsSearchableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"kIsSearchable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"kNodeTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"kNodeType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"kSubnodeCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"kSubnodeCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic installDomain;

- (int16_t)installDomainValue {
	NSNumber *result = [self installDomain];
	return [result shortValue];
}

- (void)setInstallDomainValue:(int16_t)value_ {
	[self setInstallDomain:@(value_)];
}

- (int16_t)primitiveInstallDomainValue {
	NSNumber *result = [self primitiveInstallDomain];
	return [result shortValue];
}

- (void)setPrimitiveInstallDomainValue:(int16_t)value_ {
	[self setPrimitiveInstallDomain:@(value_)];
}

@dynamic kDocumentType;

- (int16_t)kDocumentTypeValue {
	NSNumber *result = [self kDocumentType];
	return [result shortValue];
}

- (void)setKDocumentTypeValue:(int16_t)value_ {
	[self setKDocumentType:@(value_)];
}

- (int16_t)primitiveKDocumentTypeValue {
	NSNumber *result = [self primitiveKDocumentType];
	return [result shortValue];
}

- (void)setPrimitiveKDocumentTypeValue:(int16_t)value_ {
	[self setPrimitiveKDocumentType:@(value_)];
}

@dynamic kID;

- (int32_t)kIDValue {
	NSNumber *result = [self kID];
	return [result intValue];
}

- (void)setKIDValue:(int32_t)value_ {
	[self setKID:@(value_)];
}

- (int32_t)primitiveKIDValue {
	NSNumber *result = [self primitiveKID];
	return [result intValue];
}

- (void)setPrimitiveKIDValue:(int32_t)value_ {
	[self setPrimitiveKID:@(value_)];
}

@dynamic kIsSearchable;

- (BOOL)kIsSearchableValue {
	NSNumber *result = [self kIsSearchable];
	return [result boolValue];
}

- (void)setKIsSearchableValue:(BOOL)value_ {
	[self setKIsSearchable:@(value_)];
}

- (BOOL)primitiveKIsSearchableValue {
	NSNumber *result = [self primitiveKIsSearchable];
	return [result boolValue];
}

- (void)setPrimitiveKIsSearchableValue:(BOOL)value_ {
	[self setPrimitiveKIsSearchable:@(value_)];
}

@dynamic kName;

@dynamic kNodeType;

- (int16_t)kNodeTypeValue {
	NSNumber *result = [self kNodeType];
	return [result shortValue];
}

- (void)setKNodeTypeValue:(int16_t)value_ {
	[self setKNodeType:@(value_)];
}

- (int16_t)primitiveKNodeTypeValue {
	NSNumber *result = [self primitiveKNodeType];
	return [result shortValue];
}

- (void)setPrimitiveKNodeTypeValue:(int16_t)value_ {
	[self setPrimitiveKNodeType:@(value_)];
}

@dynamic kSubnodeCount;

- (int32_t)kSubnodeCountValue {
	NSNumber *result = [self kSubnodeCount];
	return [result intValue];
}

- (void)setKSubnodeCountValue:(int32_t)value_ {
	[self setKSubnodeCount:@(value_)];
}

- (int32_t)primitiveKSubnodeCountValue {
	NSNumber *result = [self primitiveKSubnodeCount];
	return [result intValue];
}

- (void)setPrimitiveKSubnodeCountValue:(int32_t)value_ {
	[self setPrimitiveKSubnodeCount:@(value_)];
}

@dynamic apiLanguages;

- (NSMutableSet<APILanguage*>*)apiLanguagesSet {
	[self willAccessValueForKey:@"apiLanguages"];

	NSMutableSet<APILanguage*> *result = (NSMutableSet<APILanguage*>*)[self mutableSetValueForKey:@"apiLanguages"];

	[self didAccessValueForKey:@"apiLanguages"];
	return result;
}

@dynamic orderedSelfs;

- (NSMutableSet<OrderedSubnode*>*)orderedSelfsSet {
	[self willAccessValueForKey:@"orderedSelfs"];

	NSMutableSet<OrderedSubnode*> *result = (NSMutableSet<OrderedSubnode*>*)[self mutableSetValueForKey:@"orderedSelfs"];

	[self didAccessValueForKey:@"orderedSelfs"];
	return result;
}

@dynamic orderedSubnodes;

- (NSMutableSet<OrderedSubnode*>*)orderedSubnodesSet {
	[self willAccessValueForKey:@"orderedSubnodes"];

	NSMutableSet<OrderedSubnode*> *result = (NSMutableSet<OrderedSubnode*>*)[self mutableSetValueForKey:@"orderedSubnodes"];

	[self didAccessValueForKey:@"orderedSubnodes"];
	return result;
}

@dynamic primaryParent;

@dynamic relatedDocsInverse;

- (NSMutableSet<TokenMetainformation*>*)relatedDocsInverseSet {
	[self willAccessValueForKey:@"relatedDocsInverse"];

	NSMutableSet<TokenMetainformation*> *result = (NSMutableSet<TokenMetainformation*>*)[self mutableSetValueForKey:@"relatedDocsInverse"];

	[self didAccessValueForKey:@"relatedDocsInverse"];
	return result;
}

@dynamic relatedNodes;

- (NSMutableSet<DSANode*>*)relatedNodesSet {
	[self willAccessValueForKey:@"relatedNodes"];

	NSMutableSet<DSANode*> *result = (NSMutableSet<DSANode*>*)[self mutableSetValueForKey:@"relatedNodes"];

	[self didAccessValueForKey:@"relatedNodes"];
	return result;
}

@dynamic relatedNodesInverse;

- (NSMutableSet<DSANode*>*)relatedNodesInverseSet {
	[self willAccessValueForKey:@"relatedNodesInverse"];

	NSMutableSet<DSANode*> *result = (NSMutableSet<DSANode*>*)[self mutableSetValueForKey:@"relatedNodesInverse"];

	[self didAccessValueForKey:@"relatedNodesInverse"];
	return result;
}

@dynamic relatedSCInverse;

- (NSMutableSet<TokenMetainformation*>*)relatedSCInverseSet {
	[self willAccessValueForKey:@"relatedSCInverse"];

	NSMutableSet<TokenMetainformation*> *result = (NSMutableSet<TokenMetainformation*>*)[self mutableSetValueForKey:@"relatedSCInverse"];

	[self didAccessValueForKey:@"relatedSCInverse"];
	return result;
}

@end

@implementation DSANodeAttributes 
+ (NSString *)installDomain {
	return @"installDomain";
}
+ (NSString *)kDocumentType {
	return @"kDocumentType";
}
+ (NSString *)kID {
	return @"kID";
}
+ (NSString *)kIsSearchable {
	return @"kIsSearchable";
}
+ (NSString *)kName {
	return @"kName";
}
+ (NSString *)kNodeType {
	return @"kNodeType";
}
+ (NSString *)kSubnodeCount {
	return @"kSubnodeCount";
}
@end

@implementation DSANodeRelationships 
+ (NSString *)apiLanguages {
	return @"apiLanguages";
}
+ (NSString *)orderedSelfs {
	return @"orderedSelfs";
}
+ (NSString *)orderedSubnodes {
	return @"orderedSubnodes";
}
+ (NSString *)primaryParent {
	return @"primaryParent";
}
+ (NSString *)relatedDocsInverse {
	return @"relatedDocsInverse";
}
+ (NSString *)relatedNodes {
	return @"relatedNodes";
}
+ (NSString *)relatedNodesInverse {
	return @"relatedNodesInverse";
}
+ (NSString *)relatedSCInverse {
	return @"relatedSCInverse";
}
@end

