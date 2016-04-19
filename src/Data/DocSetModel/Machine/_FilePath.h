// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FilePath.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface FilePathID : NSManagedObjectID {}
@end

@interface _FilePath : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) FilePathID *objectID;

@property (nonatomic, strong) NSString* path;

@end

@interface _FilePath (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;

@end

@interface FilePathAttributes: NSObject 
+ (NSString *)path;
@end

NS_ASSUME_NONNULL_END
