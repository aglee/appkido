// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DownloadableFile.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DSANode;

@interface DownloadableFileID : NSManagedObjectID {}
@end

@interface _DownloadableFile : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DownloadableFileID *objectID;

@property (nonatomic, strong) NSNumber* type;

@property (atomic) int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;

@property (nonatomic, strong) NSString* url;

@property (nonatomic, strong) DSANode *node;

@end

@interface _DownloadableFile (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;

- (DSANode*)primitiveNode;
- (void)setPrimitiveNode:(DSANode*)value;

@end

@interface DownloadableFileAttributes: NSObject 
+ (NSString *)type;
+ (NSString *)url;
@end

@interface DownloadableFileRelationships: NSObject
+ (NSString *)node;
@end

NS_ASSUME_NONNULL_END
