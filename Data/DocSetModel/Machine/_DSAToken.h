// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DSAToken.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Container;
@class APILanguage;
@class TokenMetainformation;
@class DSANode;
@class Container;
@class TokenGroup;
@class TokenMetainformation;
@class Container;
@class TokenType;

@interface DSATokenID : NSManagedObjectID {}
@end

@interface _DSAToken : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DSATokenID *objectID;

@property (nonatomic, strong) NSNumber* alphaSortOrder;

@property (atomic) int32_t alphaSortOrderValue;
- (int32_t)alphaSortOrderValue;
- (void)setAlphaSortOrderValue:(int32_t)value_;

@property (nonatomic, strong) NSNumber* firstLowercaseUTF8Byte;

@property (atomic) int16_t firstLowercaseUTF8ByteValue;
- (int16_t)firstLowercaseUTF8ByteValue;
- (void)setFirstLowercaseUTF8ByteValue:(int16_t)value_;

@property (nonatomic, strong) NSString* tokenName;

@property (nonatomic, strong, nullable) NSString* tokenUSR;

@property (nonatomic, strong, nullable) Container *container;

@property (nonatomic, strong, nullable) APILanguage *language;

@property (nonatomic, strong, nullable) TokenMetainformation *metainformation;

@property (nonatomic, strong, nullable) DSANode *parentNode;

@property (nonatomic, strong, nullable) NSSet<Container*> *protocolContainers;
- (nullable NSMutableSet<Container*>*)protocolContainersSet;

@property (nonatomic, strong, nullable) NSSet<TokenGroup*> *relatedGroups;
- (nullable NSMutableSet<TokenGroup*>*)relatedGroupsSet;

@property (nonatomic, strong, nullable) NSSet<TokenMetainformation*> *relatedTokensInverse;
- (nullable NSMutableSet<TokenMetainformation*>*)relatedTokensInverseSet;

@property (nonatomic, strong, nullable) NSSet<Container*> *superclassContainers;
- (nullable NSMutableSet<Container*>*)superclassContainersSet;

@property (nonatomic, strong) TokenType *tokenType;

@end

@interface _DSAToken (ProtocolContainersCoreDataGeneratedAccessors)
- (void)addProtocolContainers:(NSSet<Container*>*)value_;
- (void)removeProtocolContainers:(NSSet<Container*>*)value_;
- (void)addProtocolContainersObject:(Container*)value_;
- (void)removeProtocolContainersObject:(Container*)value_;

@end

@interface _DSAToken (RelatedGroupsCoreDataGeneratedAccessors)
- (void)addRelatedGroups:(NSSet<TokenGroup*>*)value_;
- (void)removeRelatedGroups:(NSSet<TokenGroup*>*)value_;
- (void)addRelatedGroupsObject:(TokenGroup*)value_;
- (void)removeRelatedGroupsObject:(TokenGroup*)value_;

@end

@interface _DSAToken (RelatedTokensInverseCoreDataGeneratedAccessors)
- (void)addRelatedTokensInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)removeRelatedTokensInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)addRelatedTokensInverseObject:(TokenMetainformation*)value_;
- (void)removeRelatedTokensInverseObject:(TokenMetainformation*)value_;

@end

@interface _DSAToken (SuperclassContainersCoreDataGeneratedAccessors)
- (void)addSuperclassContainers:(NSSet<Container*>*)value_;
- (void)removeSuperclassContainers:(NSSet<Container*>*)value_;
- (void)addSuperclassContainersObject:(Container*)value_;
- (void)removeSuperclassContainersObject:(Container*)value_;

@end

@interface _DSAToken (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveAlphaSortOrder;
- (void)setPrimitiveAlphaSortOrder:(NSNumber*)value;

- (int32_t)primitiveAlphaSortOrderValue;
- (void)setPrimitiveAlphaSortOrderValue:(int32_t)value_;

- (NSNumber*)primitiveFirstLowercaseUTF8Byte;
- (void)setPrimitiveFirstLowercaseUTF8Byte:(NSNumber*)value;

- (int16_t)primitiveFirstLowercaseUTF8ByteValue;
- (void)setPrimitiveFirstLowercaseUTF8ByteValue:(int16_t)value_;

- (NSString*)primitiveTokenName;
- (void)setPrimitiveTokenName:(NSString*)value;

- (NSString*)primitiveTokenUSR;
- (void)setPrimitiveTokenUSR:(NSString*)value;

- (Container*)primitiveContainer;
- (void)setPrimitiveContainer:(Container*)value;

- (APILanguage*)primitiveLanguage;
- (void)setPrimitiveLanguage:(APILanguage*)value;

- (TokenMetainformation*)primitiveMetainformation;
- (void)setPrimitiveMetainformation:(TokenMetainformation*)value;

- (DSANode*)primitiveParentNode;
- (void)setPrimitiveParentNode:(DSANode*)value;

- (NSMutableSet<Container*>*)primitiveProtocolContainers;
- (void)setPrimitiveProtocolContainers:(NSMutableSet<Container*>*)value;

- (NSMutableSet<TokenGroup*>*)primitiveRelatedGroups;
- (void)setPrimitiveRelatedGroups:(NSMutableSet<TokenGroup*>*)value;

- (NSMutableSet<TokenMetainformation*>*)primitiveRelatedTokensInverse;
- (void)setPrimitiveRelatedTokensInverse:(NSMutableSet<TokenMetainformation*>*)value;

- (NSMutableSet<Container*>*)primitiveSuperclassContainers;
- (void)setPrimitiveSuperclassContainers:(NSMutableSet<Container*>*)value;

- (TokenType*)primitiveTokenType;
- (void)setPrimitiveTokenType:(TokenType*)value;

@end

@interface DSATokenAttributes: NSObject 
+ (NSString *)alphaSortOrder;
+ (NSString *)firstLowercaseUTF8Byte;
+ (NSString *)tokenName;
+ (NSString *)tokenUSR;
@end

@interface DSATokenRelationships: NSObject
+ (NSString *)container;
+ (NSString *)language;
+ (NSString *)metainformation;
+ (NSString *)parentNode;
+ (NSString *)protocolContainers;
+ (NSString *)relatedGroups;
+ (NSString *)relatedTokensInverse;
+ (NSString *)superclassContainers;
+ (NSString *)tokenType;
@end

NS_ASSUME_NONNULL_END
