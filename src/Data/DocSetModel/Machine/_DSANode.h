// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DSANode.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class APILanguage;
@class OrderedSubnode;
@class OrderedSubnode;
@class DSANode;
@class TokenMetainformation;
@class DSANode;
@class DSANode;
@class TokenMetainformation;

@interface DSANodeID : NSManagedObjectID {}
@end

@interface _DSANode : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DSANodeID *objectID;

@property (nonatomic, strong, nullable) NSNumber* installDomain;

@property (atomic) int16_t installDomainValue;
- (int16_t)installDomainValue;
- (void)setInstallDomainValue:(int16_t)value_;

@property (nonatomic, strong) NSNumber* kDocumentType;

@property (atomic) int16_t kDocumentTypeValue;
- (int16_t)kDocumentTypeValue;
- (void)setKDocumentTypeValue:(int16_t)value_;

@property (nonatomic, strong) NSNumber* kID;

@property (atomic) int32_t kIDValue;
- (int32_t)kIDValue;
- (void)setKIDValue:(int32_t)value_;

@property (nonatomic, strong) NSNumber* kIsSearchable;

@property (atomic) BOOL kIsSearchableValue;
- (BOOL)kIsSearchableValue;
- (void)setKIsSearchableValue:(BOOL)value_;

@property (nonatomic, strong) NSString* kName;

@property (nonatomic, strong) NSNumber* kNodeType;

@property (atomic) int16_t kNodeTypeValue;
- (int16_t)kNodeTypeValue;
- (void)setKNodeTypeValue:(int16_t)value_;

@property (nonatomic, strong) NSNumber* kSubnodeCount;

@property (atomic) int32_t kSubnodeCountValue;
- (int32_t)kSubnodeCountValue;
- (void)setKSubnodeCountValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSSet<APILanguage*> *apiLanguages;
- (nullable NSMutableSet<APILanguage*>*)apiLanguagesSet;

@property (nonatomic, strong, nullable) NSSet<OrderedSubnode*> *orderedSelfs;
- (nullable NSMutableSet<OrderedSubnode*>*)orderedSelfsSet;

@property (nonatomic, strong, nullable) NSSet<OrderedSubnode*> *orderedSubnodes;
- (nullable NSMutableSet<OrderedSubnode*>*)orderedSubnodesSet;

@property (nonatomic, strong, nullable) DSANode *primaryParent;

@property (nonatomic, strong, nullable) NSSet<TokenMetainformation*> *relatedDocsInverse;
- (nullable NSMutableSet<TokenMetainformation*>*)relatedDocsInverseSet;

@property (nonatomic, strong, nullable) NSSet<DSANode*> *relatedNodes;
- (nullable NSMutableSet<DSANode*>*)relatedNodesSet;

@property (nonatomic, strong, nullable) NSSet<DSANode*> *relatedNodesInverse;
- (nullable NSMutableSet<DSANode*>*)relatedNodesInverseSet;

@property (nonatomic, strong, nullable) NSSet<TokenMetainformation*> *relatedSCInverse;
- (nullable NSMutableSet<TokenMetainformation*>*)relatedSCInverseSet;

@end

@interface _DSANode (ApiLanguagesCoreDataGeneratedAccessors)
- (void)addApiLanguages:(NSSet<APILanguage*>*)value_;
- (void)removeApiLanguages:(NSSet<APILanguage*>*)value_;
- (void)addApiLanguagesObject:(APILanguage*)value_;
- (void)removeApiLanguagesObject:(APILanguage*)value_;

@end

@interface _DSANode (OrderedSelfsCoreDataGeneratedAccessors)
- (void)addOrderedSelfs:(NSSet<OrderedSubnode*>*)value_;
- (void)removeOrderedSelfs:(NSSet<OrderedSubnode*>*)value_;
- (void)addOrderedSelfsObject:(OrderedSubnode*)value_;
- (void)removeOrderedSelfsObject:(OrderedSubnode*)value_;

@end

@interface _DSANode (OrderedSubnodesCoreDataGeneratedAccessors)
- (void)addOrderedSubnodes:(NSSet<OrderedSubnode*>*)value_;
- (void)removeOrderedSubnodes:(NSSet<OrderedSubnode*>*)value_;
- (void)addOrderedSubnodesObject:(OrderedSubnode*)value_;
- (void)removeOrderedSubnodesObject:(OrderedSubnode*)value_;

@end

@interface _DSANode (RelatedDocsInverseCoreDataGeneratedAccessors)
- (void)addRelatedDocsInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)removeRelatedDocsInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)addRelatedDocsInverseObject:(TokenMetainformation*)value_;
- (void)removeRelatedDocsInverseObject:(TokenMetainformation*)value_;

@end

@interface _DSANode (RelatedNodesCoreDataGeneratedAccessors)
- (void)addRelatedNodes:(NSSet<DSANode*>*)value_;
- (void)removeRelatedNodes:(NSSet<DSANode*>*)value_;
- (void)addRelatedNodesObject:(DSANode*)value_;
- (void)removeRelatedNodesObject:(DSANode*)value_;

@end

@interface _DSANode (RelatedNodesInverseCoreDataGeneratedAccessors)
- (void)addRelatedNodesInverse:(NSSet<DSANode*>*)value_;
- (void)removeRelatedNodesInverse:(NSSet<DSANode*>*)value_;
- (void)addRelatedNodesInverseObject:(DSANode*)value_;
- (void)removeRelatedNodesInverseObject:(DSANode*)value_;

@end

@interface _DSANode (RelatedSCInverseCoreDataGeneratedAccessors)
- (void)addRelatedSCInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)removeRelatedSCInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)addRelatedSCInverseObject:(TokenMetainformation*)value_;
- (void)removeRelatedSCInverseObject:(TokenMetainformation*)value_;

@end

@interface _DSANode (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveInstallDomain;
- (void)setPrimitiveInstallDomain:(NSNumber*)value;

- (int16_t)primitiveInstallDomainValue;
- (void)setPrimitiveInstallDomainValue:(int16_t)value_;

- (NSNumber*)primitiveKDocumentType;
- (void)setPrimitiveKDocumentType:(NSNumber*)value;

- (int16_t)primitiveKDocumentTypeValue;
- (void)setPrimitiveKDocumentTypeValue:(int16_t)value_;

- (NSNumber*)primitiveKID;
- (void)setPrimitiveKID:(NSNumber*)value;

- (int32_t)primitiveKIDValue;
- (void)setPrimitiveKIDValue:(int32_t)value_;

- (NSNumber*)primitiveKIsSearchable;
- (void)setPrimitiveKIsSearchable:(NSNumber*)value;

- (BOOL)primitiveKIsSearchableValue;
- (void)setPrimitiveKIsSearchableValue:(BOOL)value_;

- (NSString*)primitiveKName;
- (void)setPrimitiveKName:(NSString*)value;

- (NSNumber*)primitiveKNodeType;
- (void)setPrimitiveKNodeType:(NSNumber*)value;

- (int16_t)primitiveKNodeTypeValue;
- (void)setPrimitiveKNodeTypeValue:(int16_t)value_;

- (NSNumber*)primitiveKSubnodeCount;
- (void)setPrimitiveKSubnodeCount:(NSNumber*)value;

- (int32_t)primitiveKSubnodeCountValue;
- (void)setPrimitiveKSubnodeCountValue:(int32_t)value_;

- (NSMutableSet<APILanguage*>*)primitiveApiLanguages;
- (void)setPrimitiveApiLanguages:(NSMutableSet<APILanguage*>*)value;

- (NSMutableSet<OrderedSubnode*>*)primitiveOrderedSelfs;
- (void)setPrimitiveOrderedSelfs:(NSMutableSet<OrderedSubnode*>*)value;

- (NSMutableSet<OrderedSubnode*>*)primitiveOrderedSubnodes;
- (void)setPrimitiveOrderedSubnodes:(NSMutableSet<OrderedSubnode*>*)value;

- (DSANode*)primitivePrimaryParent;
- (void)setPrimitivePrimaryParent:(DSANode*)value;

- (NSMutableSet<TokenMetainformation*>*)primitiveRelatedDocsInverse;
- (void)setPrimitiveRelatedDocsInverse:(NSMutableSet<TokenMetainformation*>*)value;

- (NSMutableSet<DSANode*>*)primitiveRelatedNodes;
- (void)setPrimitiveRelatedNodes:(NSMutableSet<DSANode*>*)value;

- (NSMutableSet<DSANode*>*)primitiveRelatedNodesInverse;
- (void)setPrimitiveRelatedNodesInverse:(NSMutableSet<DSANode*>*)value;

- (NSMutableSet<TokenMetainformation*>*)primitiveRelatedSCInverse;
- (void)setPrimitiveRelatedSCInverse:(NSMutableSet<TokenMetainformation*>*)value;

@end

@interface DSANodeAttributes: NSObject 
+ (NSString *)installDomain;
+ (NSString *)kDocumentType;
+ (NSString *)kID;
+ (NSString *)kIsSearchable;
+ (NSString *)kName;
+ (NSString *)kNodeType;
+ (NSString *)kSubnodeCount;
@end

@interface DSANodeRelationships: NSObject
+ (NSString *)apiLanguages;
+ (NSString *)orderedSelfs;
+ (NSString *)orderedSubnodes;
+ (NSString *)primaryParent;
+ (NSString *)relatedDocsInverse;
+ (NSString *)relatedNodes;
+ (NSString *)relatedNodesInverse;
+ (NSString *)relatedSCInverse;
@end

NS_ASSUME_NONNULL_END
