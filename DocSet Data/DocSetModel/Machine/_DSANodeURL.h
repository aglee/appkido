// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DSANodeURL.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DSANode;

@interface DSANodeURLID : NSManagedObjectID {}
@end

@interface _DSANodeURL : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) DSANodeURLID *objectID;

@property (nonatomic, strong, nullable) NSString* anchor;

@property (nonatomic, strong, nullable) NSString* baseURL;

@property (nonatomic, strong, nullable) NSNumber* checksum;

@property (atomic) int32_t checksumValue;
- (int32_t)checksumValue;
- (void)setChecksumValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSString* fileName;

@property (nonatomic, strong, nullable) NSString* path;

@property (nonatomic, strong, nullable) DSANode *node;

@end

@interface _DSANodeURL (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAnchor;
- (void)setPrimitiveAnchor:(NSString*)value;

- (NSString*)primitiveBaseURL;
- (void)setPrimitiveBaseURL:(NSString*)value;

- (NSNumber*)primitiveChecksum;
- (void)setPrimitiveChecksum:(NSNumber*)value;

- (int32_t)primitiveChecksumValue;
- (void)setPrimitiveChecksumValue:(int32_t)value_;

- (NSString*)primitiveFileName;
- (void)setPrimitiveFileName:(NSString*)value;

- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;

- (DSANode*)primitiveNode;
- (void)setPrimitiveNode:(DSANode*)value;

@end

@interface DSANodeURLAttributes: NSObject 
+ (NSString *)anchor;
+ (NSString *)baseURL;
+ (NSString *)checksum;
+ (NSString *)fileName;
+ (NSString *)path;
@end

@interface DSANodeURLRelationships: NSObject
+ (NSString *)node;
@end

NS_ASSUME_NONNULL_END
