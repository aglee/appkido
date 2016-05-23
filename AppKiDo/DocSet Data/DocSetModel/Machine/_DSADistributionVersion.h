// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DSADistributionVersion.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class TokenMetainformation;
@class TokenMetainformation;
@class TokenMetainformation;

@interface DSADistributionVersionID : NSManagedObjectID {}
@end

@interface _DSADistributionVersion : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DSADistributionVersionID *objectID;

@property (nonatomic, strong) NSNumber* architectureFlags;

@property (atomic) int32_t architectureFlagsValue;
- (int32_t)architectureFlagsValue;
- (void)setArchitectureFlagsValue:(int32_t)value_;

@property (nonatomic, strong) NSString* distributionName;

@property (nonatomic, strong) NSString* versionString;

@property (nonatomic, strong, nullable) NSSet<TokenMetainformation*> *deprecatedInInverse;
- (nullable NSMutableSet<TokenMetainformation*>*)deprecatedInInverseSet;

@property (nonatomic, strong, nullable) NSSet<TokenMetainformation*> *introducedInInverse;
- (nullable NSMutableSet<TokenMetainformation*>*)introducedInInverseSet;

@property (nonatomic, strong, nullable) NSSet<TokenMetainformation*> *removedAfterInverse;
- (nullable NSMutableSet<TokenMetainformation*>*)removedAfterInverseSet;

@end

@interface _DSADistributionVersion (DeprecatedInInverseCoreDataGeneratedAccessors)
- (void)addDeprecatedInInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)removeDeprecatedInInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)addDeprecatedInInverseObject:(TokenMetainformation*)value_;
- (void)removeDeprecatedInInverseObject:(TokenMetainformation*)value_;

@end

@interface _DSADistributionVersion (IntroducedInInverseCoreDataGeneratedAccessors)
- (void)addIntroducedInInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)removeIntroducedInInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)addIntroducedInInverseObject:(TokenMetainformation*)value_;
- (void)removeIntroducedInInverseObject:(TokenMetainformation*)value_;

@end

@interface _DSADistributionVersion (RemovedAfterInverseCoreDataGeneratedAccessors)
- (void)addRemovedAfterInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)removeRemovedAfterInverse:(NSSet<TokenMetainformation*>*)value_;
- (void)addRemovedAfterInverseObject:(TokenMetainformation*)value_;
- (void)removeRemovedAfterInverseObject:(TokenMetainformation*)value_;

@end

@interface _DSADistributionVersion (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveArchitectureFlags;
- (void)setPrimitiveArchitectureFlags:(NSNumber*)value;

- (int32_t)primitiveArchitectureFlagsValue;
- (void)setPrimitiveArchitectureFlagsValue:(int32_t)value_;

- (NSString*)primitiveDistributionName;
- (void)setPrimitiveDistributionName:(NSString*)value;

- (NSString*)primitiveVersionString;
- (void)setPrimitiveVersionString:(NSString*)value;

- (NSMutableSet<TokenMetainformation*>*)primitiveDeprecatedInInverse;
- (void)setPrimitiveDeprecatedInInverse:(NSMutableSet<TokenMetainformation*>*)value;

- (NSMutableSet<TokenMetainformation*>*)primitiveIntroducedInInverse;
- (void)setPrimitiveIntroducedInInverse:(NSMutableSet<TokenMetainformation*>*)value;

- (NSMutableSet<TokenMetainformation*>*)primitiveRemovedAfterInverse;
- (void)setPrimitiveRemovedAfterInverse:(NSMutableSet<TokenMetainformation*>*)value;

@end

@interface DSADistributionVersionAttributes: NSObject 
+ (NSString *)architectureFlags;
+ (NSString *)distributionName;
+ (NSString *)versionString;
@end

@interface DSADistributionVersionRelationships: NSObject
+ (NSString *)deprecatedInInverse;
+ (NSString *)introducedInInverse;
+ (NSString *)removedAfterInverse;
@end

NS_ASSUME_NONNULL_END
