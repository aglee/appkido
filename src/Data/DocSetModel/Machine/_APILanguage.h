// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to APILanguage.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DSANode;

@interface APILanguageID : NSManagedObjectID {}
@end

@interface _APILanguage : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) APILanguageID *objectID;

@property (nonatomic, strong, nullable) NSString* fullName;

@property (nonatomic, strong, nullable) NSSet<DSANode*> *nodes;
- (nullable NSMutableSet<DSANode*>*)nodesSet;

@end

@interface _APILanguage (NodesCoreDataGeneratedAccessors)
- (void)addNodes:(NSSet<DSANode*>*)value_;
- (void)removeNodes:(NSSet<DSANode*>*)value_;
- (void)addNodesObject:(DSANode*)value_;
- (void)removeNodesObject:(DSANode*)value_;

@end

@interface _APILanguage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(NSString*)value;

- (NSMutableSet<DSANode*>*)primitiveNodes;
- (void)setPrimitiveNodes:(NSMutableSet<DSANode*>*)value;

@end

@interface APILanguageAttributes: NSObject 
+ (NSString *)fullName;
@end

@interface APILanguageRelationships: NSObject
+ (NSString *)nodes;
@end

NS_ASSUME_NONNULL_END
