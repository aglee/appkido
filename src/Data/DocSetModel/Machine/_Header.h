// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Header.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface HeaderID : NSManagedObjectID {}
@end

@interface _Header : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) HeaderID *objectID;

@property (nonatomic, strong, nullable) NSString* frameworkName;

@property (nonatomic, strong) NSString* headerPath;

@end

@interface _Header (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFrameworkName;
- (void)setPrimitiveFrameworkName:(NSString*)value;

- (NSString*)primitiveHeaderPath;
- (void)setPrimitiveHeaderPath:(NSString*)value;

@end

@interface HeaderAttributes: NSObject 
+ (NSString *)frameworkName;
+ (NSString *)headerPath;
@end

NS_ASSUME_NONNULL_END
