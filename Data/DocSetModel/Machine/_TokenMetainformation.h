// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TokenMetainformation.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Header;
@class DSADistributionVersion;
@class FilePath;
@class DSADistributionVersion;
@class Parameter;
@class DSANode;
@class DSANode;
@class DSAToken;
@class DSADistributionVersion;
@class ReturnValue;
@class DSAToken;

@interface TokenMetainformationID : NSManagedObjectID {}
@end

@interface _TokenMetainformation : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TokenMetainformationID *objectID;

@property (nonatomic, strong, nullable) NSString* abstract;

@property (nonatomic, strong, nullable) NSString* anchor;

@property (nonatomic, strong, nullable) NSString* declaration;

@property (nonatomic, strong, nullable) NSString* deprecationSummary;

@property (nonatomic, strong, nullable) Header *declaredIn;

@property (nonatomic, strong, nullable) NSSet<DSADistributionVersion*> *deprecatedInVersions;
- (nullable NSMutableSet<DSADistributionVersion*>*)deprecatedInVersionsSet;

@property (nonatomic, strong, nullable) FilePath *file;

@property (nonatomic, strong, nullable) NSSet<DSADistributionVersion*> *introducedInVersions;
- (nullable NSMutableSet<DSADistributionVersion*>*)introducedInVersionsSet;

@property (nonatomic, strong, nullable) NSSet<Parameter*> *parameters;
- (nullable NSMutableSet<Parameter*>*)parametersSet;

@property (nonatomic, strong, nullable) NSSet<DSANode*> *relatedDocuments;
- (nullable NSMutableSet<DSANode*>*)relatedDocumentsSet;

@property (nonatomic, strong, nullable) NSSet<DSANode*> *relatedSampleCode;
- (nullable NSMutableSet<DSANode*>*)relatedSampleCodeSet;

@property (nonatomic, strong, nullable) NSSet<DSAToken*> *relatedTokens;
- (nullable NSMutableSet<DSAToken*>*)relatedTokensSet;

@property (nonatomic, strong, nullable) NSSet<DSADistributionVersion*> *removedAfterVersions;
- (nullable NSMutableSet<DSADistributionVersion*>*)removedAfterVersionsSet;

@property (nonatomic, strong, nullable) ReturnValue *returnValue;

@property (nonatomic, strong) DSAToken *token;

@end

@interface _TokenMetainformation (DeprecatedInVersionsCoreDataGeneratedAccessors)
- (void)addDeprecatedInVersions:(NSSet<DSADistributionVersion*>*)value_;
- (void)removeDeprecatedInVersions:(NSSet<DSADistributionVersion*>*)value_;
- (void)addDeprecatedInVersionsObject:(DSADistributionVersion*)value_;
- (void)removeDeprecatedInVersionsObject:(DSADistributionVersion*)value_;

@end

@interface _TokenMetainformation (IntroducedInVersionsCoreDataGeneratedAccessors)
- (void)addIntroducedInVersions:(NSSet<DSADistributionVersion*>*)value_;
- (void)removeIntroducedInVersions:(NSSet<DSADistributionVersion*>*)value_;
- (void)addIntroducedInVersionsObject:(DSADistributionVersion*)value_;
- (void)removeIntroducedInVersionsObject:(DSADistributionVersion*)value_;

@end

@interface _TokenMetainformation (ParametersCoreDataGeneratedAccessors)
- (void)addParameters:(NSSet<Parameter*>*)value_;
- (void)removeParameters:(NSSet<Parameter*>*)value_;
- (void)addParametersObject:(Parameter*)value_;
- (void)removeParametersObject:(Parameter*)value_;

@end

@interface _TokenMetainformation (RelatedDocumentsCoreDataGeneratedAccessors)
- (void)addRelatedDocuments:(NSSet<DSANode*>*)value_;
- (void)removeRelatedDocuments:(NSSet<DSANode*>*)value_;
- (void)addRelatedDocumentsObject:(DSANode*)value_;
- (void)removeRelatedDocumentsObject:(DSANode*)value_;

@end

@interface _TokenMetainformation (RelatedSampleCodeCoreDataGeneratedAccessors)
- (void)addRelatedSampleCode:(NSSet<DSANode*>*)value_;
- (void)removeRelatedSampleCode:(NSSet<DSANode*>*)value_;
- (void)addRelatedSampleCodeObject:(DSANode*)value_;
- (void)removeRelatedSampleCodeObject:(DSANode*)value_;

@end

@interface _TokenMetainformation (RelatedTokensCoreDataGeneratedAccessors)
- (void)addRelatedTokens:(NSSet<DSAToken*>*)value_;
- (void)removeRelatedTokens:(NSSet<DSAToken*>*)value_;
- (void)addRelatedTokensObject:(DSAToken*)value_;
- (void)removeRelatedTokensObject:(DSAToken*)value_;

@end

@interface _TokenMetainformation (RemovedAfterVersionsCoreDataGeneratedAccessors)
- (void)addRemovedAfterVersions:(NSSet<DSADistributionVersion*>*)value_;
- (void)removeRemovedAfterVersions:(NSSet<DSADistributionVersion*>*)value_;
- (void)addRemovedAfterVersionsObject:(DSADistributionVersion*)value_;
- (void)removeRemovedAfterVersionsObject:(DSADistributionVersion*)value_;

@end

@interface _TokenMetainformation (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAbstract;
- (void)setPrimitiveAbstract:(NSString*)value;

- (NSString*)primitiveAnchor;
- (void)setPrimitiveAnchor:(NSString*)value;

- (NSString*)primitiveDeclaration;
- (void)setPrimitiveDeclaration:(NSString*)value;

- (NSString*)primitiveDeprecationSummary;
- (void)setPrimitiveDeprecationSummary:(NSString*)value;

- (Header*)primitiveDeclaredIn;
- (void)setPrimitiveDeclaredIn:(Header*)value;

- (NSMutableSet<DSADistributionVersion*>*)primitiveDeprecatedInVersions;
- (void)setPrimitiveDeprecatedInVersions:(NSMutableSet<DSADistributionVersion*>*)value;

- (FilePath*)primitiveFile;
- (void)setPrimitiveFile:(FilePath*)value;

- (NSMutableSet<DSADistributionVersion*>*)primitiveIntroducedInVersions;
- (void)setPrimitiveIntroducedInVersions:(NSMutableSet<DSADistributionVersion*>*)value;

- (NSMutableSet<Parameter*>*)primitiveParameters;
- (void)setPrimitiveParameters:(NSMutableSet<Parameter*>*)value;

- (NSMutableSet<DSANode*>*)primitiveRelatedDocuments;
- (void)setPrimitiveRelatedDocuments:(NSMutableSet<DSANode*>*)value;

- (NSMutableSet<DSANode*>*)primitiveRelatedSampleCode;
- (void)setPrimitiveRelatedSampleCode:(NSMutableSet<DSANode*>*)value;

- (NSMutableSet<DSAToken*>*)primitiveRelatedTokens;
- (void)setPrimitiveRelatedTokens:(NSMutableSet<DSAToken*>*)value;

- (NSMutableSet<DSADistributionVersion*>*)primitiveRemovedAfterVersions;
- (void)setPrimitiveRemovedAfterVersions:(NSMutableSet<DSADistributionVersion*>*)value;

- (ReturnValue*)primitiveReturnValue;
- (void)setPrimitiveReturnValue:(ReturnValue*)value;

- (DSAToken*)primitiveToken;
- (void)setPrimitiveToken:(DSAToken*)value;

@end

@interface TokenMetainformationAttributes: NSObject 
+ (NSString *)abstract;
+ (NSString *)anchor;
+ (NSString *)declaration;
+ (NSString *)deprecationSummary;
@end

@interface TokenMetainformationRelationships: NSObject
+ (NSString *)declaredIn;
+ (NSString *)deprecatedInVersions;
+ (NSString *)file;
+ (NSString *)introducedInVersions;
+ (NSString *)parameters;
+ (NSString *)relatedDocuments;
+ (NSString *)relatedSampleCode;
+ (NSString *)relatedTokens;
+ (NSString *)removedAfterVersions;
+ (NSString *)returnValue;
+ (NSString *)token;
@end

NS_ASSUME_NONNULL_END
