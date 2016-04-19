// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DocSet.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DSANode;

@interface DocSetID : NSManagedObjectID {}
@end

@interface _DocSet : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DocSetID *objectID;

@property (nonatomic, strong) NSString* configurationVersion;

@property (nonatomic, strong, nullable) DSANode *rootNode;

@end

@interface _DocSet (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveConfigurationVersion;
- (void)setPrimitiveConfigurationVersion:(NSString*)value;

- (DSANode*)primitiveRootNode;
- (void)setPrimitiveRootNode:(DSANode*)value;

@end

@interface DocSetAttributes: NSObject 
+ (NSString *)configurationVersion;
@end

@interface DocSetRelationships: NSObject
+ (NSString *)rootNode;
@end

@interface DocSetUserInfo: NSObject 
+ (NSString *)DocSetModelVersion;
@end

NS_ASSUME_NONNULL_END
