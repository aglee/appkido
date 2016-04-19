// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NodeUUID.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DSANode;

@interface NodeUUIDID : NSManagedObjectID {}
@end

@interface _NodeUUID : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) NodeUUIDID *objectID;

@property (nonatomic, strong) NSString* uuid;

@property (nonatomic, strong) DSANode *node;

@end

@interface _NodeUUID (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;

- (DSANode*)primitiveNode;
- (void)setPrimitiveNode:(DSANode*)value;

@end

@interface NodeUUIDAttributes: NSObject 
+ (NSString *)uuid;
@end

@interface NodeUUIDRelationships: NSObject
+ (NSString *)node;
@end

NS_ASSUME_NONNULL_END
