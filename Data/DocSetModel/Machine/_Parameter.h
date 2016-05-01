// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Parameter.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ParameterID : NSManagedObjectID {}
@end

@interface _Parameter : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ParameterID *objectID;

@property (nonatomic, strong, nullable) NSString* abstract;

@property (nonatomic, strong) NSNumber* order;

@property (atomic) int16_t orderValue;
- (int16_t)orderValue;
- (void)setOrderValue:(int16_t)value_;

@property (nonatomic, strong) NSString* parameterName;

@end

@interface _Parameter (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAbstract;
- (void)setPrimitiveAbstract:(NSString*)value;

- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int16_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int16_t)value_;

- (NSString*)primitiveParameterName;
- (void)setPrimitiveParameterName:(NSString*)value;

@end

@interface ParameterAttributes: NSObject 
+ (NSString *)abstract;
+ (NSString *)order;
+ (NSString *)parameterName;
@end

NS_ASSUME_NONNULL_END
