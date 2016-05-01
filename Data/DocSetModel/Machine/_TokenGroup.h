// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TokenGroup.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class DSAToken;

@interface TokenGroupID : NSManagedObjectID {}
@end

@interface _TokenGroup : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TokenGroupID *objectID;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) NSSet<DSAToken*> *tokens;
- (nullable NSMutableSet<DSAToken*>*)tokensSet;

@end

@interface _TokenGroup (TokensCoreDataGeneratedAccessors)
- (void)addTokens:(NSSet<DSAToken*>*)value_;
- (void)removeTokens:(NSSet<DSAToken*>*)value_;
- (void)addTokensObject:(DSAToken*)value_;
- (void)removeTokensObject:(DSAToken*)value_;

@end

@interface _TokenGroup (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSMutableSet<DSAToken*>*)primitiveTokens;
- (void)setPrimitiveTokens:(NSMutableSet<DSAToken*>*)value;

@end

@interface TokenGroupAttributes: NSObject 
+ (NSString *)title;
@end

@interface TokenGroupRelationships: NSObject
+ (NSString *)tokens;
@end

NS_ASSUME_NONNULL_END
