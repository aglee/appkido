//
//  AKDatabase+Private.h
//  AppKiDo
//
//  Created by Andy Lee on 5/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"
#import "DocSetModel.h"

/*!
 * This header should only be imported by the .m files for AKDatabase and its
 * categories.
 */
@interface AKDatabase ()
@property (strong, readonly) AKNamedObjectGroup *frameworksGroup;
@property (copy, readonly) NSMutableDictionary *classTokensByName;
@property (copy, readonly) NSMutableDictionary *protocolTokensByName;
@end

#pragma mark -

@interface AKDatabase (ImportUtils)

- (AKManagedObjectQuery *)_queryWithEntityName:(NSString *)entityName;
- (NSArray *)_fetchTokenMOsWithLanguage:(NSString *)languageName tokenType:(NSString *)tokenType;

@end

#pragma mark -

@interface AKDatabase (ImportFrameworks)

- (void)_importFrameworks;
- (AKFramework *)_frameworkForTokenMOAddIfAbsent:(DSAToken *)tokenMO;
- (AKFramework *)_frameworkWithNameAddIfAbsent:(NSString *)frameworkName;
- (NSString *)_frameworkNameForTokenMO:(DSAToken *)tokenMO;

@end

#pragma mark -

@interface AKDatabase (ImportObjC)
- (void)_importObjectiveCTokens;
- (AKProtocolToken *)_getOrAddProtocolTokenWithName:(NSString *)protocolName;
- (AKClassToken *)_getOrAddClassTokenWithName:(NSString *)className;
@end

#pragma mark -

@interface AKDatabase (ImportC)
- (void)_importCTokens;
@end

