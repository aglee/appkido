// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ReturnValue.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ReturnValueID : NSManagedObjectID {}
@end

@interface _ReturnValue : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ReturnValueID *objectID;

@property (nonatomic, strong, nullable) NSString* abstract;

@end

@interface _ReturnValue (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAbstract;
- (void)setPrimitiveAbstract:(NSString*)value;

@end

@interface ReturnValueAttributes: NSObject 
+ (NSString *)abstract;
@end

NS_ASSUME_NONNULL_END
