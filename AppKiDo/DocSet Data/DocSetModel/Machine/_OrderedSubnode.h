// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OrderedSubnode.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DSANode;
@class DSANode;

@interface OrderedSubnodeID : NSManagedObjectID {}
@end

@interface _OrderedSubnode : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) OrderedSubnodeID *objectID;

@property (nonatomic, strong) NSNumber* order;

@property (atomic) int16_t orderValue;
- (int16_t)orderValue;
- (void)setOrderValue:(int16_t)value_;

@property (nonatomic, strong) DSANode *node;

@property (nonatomic, strong) DSANode *parent;

@end

@interface _OrderedSubnode (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int16_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int16_t)value_;

- (DSANode*)primitiveNode;
- (void)setPrimitiveNode:(DSANode*)value;

- (DSANode*)primitiveParent;
- (void)setPrimitiveParent:(DSANode*)value;

@end

@interface OrderedSubnodeAttributes: NSObject 
+ (NSString *)order;
@end

@interface OrderedSubnodeRelationships: NSObject
+ (NSString *)node;
+ (NSString *)parent;
@end

NS_ASSUME_NONNULL_END
