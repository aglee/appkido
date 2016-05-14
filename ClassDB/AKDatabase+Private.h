//
//  AKDatabase+Private.h
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"
#import "AKBindingToken.h"
#import "AKCategoryToken.h"
#import "AKFrameworkConstants.h"
#import "AKDevToolsUtils.h"
#import "AKPrefUtils.h"
#import "AKClassToken.h"
#import "AKClassMethodToken.h"
#import "AKInstanceMethodToken.h"
#import "AKPropertyToken.h"
#import "AKProtocolToken.h"
#import "AKGroupItem.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"
#import "AKRegexUtils.h"
#import "DIGSLog.h"
#import "AKDocSetQuery.h"
#import "QuietLog.h"


@interface AKDatabase ()
@property (copy, readwrite) NSArray *frameworkNames;
@property (copy, readonly) NSMutableDictionary *classTokensByName;
@property (copy, readonly) NSMutableDictionary *protocolTokensByName;

- (AKDocSetQuery *)_queryWithEntityName:(NSString *)entityName;
- (NSArray *)_arrayWithTokenMOsForLanguage:(NSString *)languageName;
@end


@interface AKDatabase (PrivateObjC)
- (void)_importObjectiveCTokens;
@end


@interface AKDatabase (PrivateC)
- (void)_importCTokens;
@end
