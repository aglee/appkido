// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Container.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DSAToken;
@class DSAToken;

@interface ContainerID : NSManagedObjectID {}
@end

@interface _Container : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ContainerID *objectID;

@property (nonatomic, strong) NSString* containerName;

@property (nonatomic, strong, nullable) NSSet<DSAToken*> *adoptedBy;
- (nullable NSMutableSet<DSAToken*>*)adoptedBySet;

@property (nonatomic, strong, nullable) NSSet<DSAToken*> *subclassedBy;
- (nullable NSMutableSet<DSAToken*>*)subclassedBySet;

@end

@interface _Container (AdoptedByCoreDataGeneratedAccessors)
- (void)addAdoptedBy:(NSSet<DSAToken*>*)value_;
- (void)removeAdoptedBy:(NSSet<DSAToken*>*)value_;
- (void)addAdoptedByObject:(DSAToken*)value_;
- (void)removeAdoptedByObject:(DSAToken*)value_;

@end

@interface _Container (SubclassedByCoreDataGeneratedAccessors)
- (void)addSubclassedBy:(NSSet<DSAToken*>*)value_;
- (void)removeSubclassedBy:(NSSet<DSAToken*>*)value_;
- (void)addSubclassedByObject:(DSAToken*)value_;
- (void)removeSubclassedByObject:(DSAToken*)value_;

@end

@interface _Container (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveContainerName;
- (void)setPrimitiveContainerName:(NSString*)value;

- (NSMutableSet<DSAToken*>*)primitiveAdoptedBy;
- (void)setPrimitiveAdoptedBy:(NSMutableSet<DSAToken*>*)value;

- (NSMutableSet<DSAToken*>*)primitiveSubclassedBy;
- (void)setPrimitiveSubclassedBy:(NSMutableSet<DSAToken*>*)value;

@end

@interface ContainerAttributes: NSObject 
+ (NSString *)containerName;
@end

@interface ContainerRelationships: NSObject
+ (NSString *)adoptedBy;
+ (NSString *)subclassedBy;
@end

NS_ASSUME_NONNULL_END
