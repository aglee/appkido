//
//  AKDatabase+Private.h
//  AppKiDo
//
//  Created by Andy Lee on 5/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"

@class AKTokenInferredInfo;

@interface AKDatabase ()
@property (strong, readonly) AKNamedObjectGroup *frameworksGroup;
@property (copy, readonly) NSMutableDictionary *classTokensByName;
@property (copy, readonly) NSMutableDictionary *protocolTokensByName;

- (AKManagedObjectQuery *)_queryWithEntityName:(NSString *)entityName;
- (NSArray *)_arrayWithTokenMOsForLanguage:(NSString *)languageName;
- (NSString *)_frameworkNameForTokenMO:(DSAToken *)tokenMO;
@end


@interface AKDatabase (PrivateObjC)
- (void)_importObjectiveCTokens;
@end


@interface AKDatabase (PrivateC)
- (void)_importCTokens;
@end
