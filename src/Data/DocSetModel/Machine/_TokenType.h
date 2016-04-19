// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TokenType.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TokenTypeID : NSManagedObjectID {}
@end

@interface _TokenType : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TokenTypeID *objectID;

@property (nonatomic, strong) NSString* typeName;

@end

@interface _TokenType (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveTypeName;
- (void)setPrimitiveTypeName:(NSString*)value;

@end

@interface TokenTypeAttributes: NSObject 
+ (NSString *)typeName;
@end

NS_ASSUME_NONNULL_END
