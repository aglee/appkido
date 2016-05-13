//
//  AKDatabase+Private.h
//  AppKiDo
//
//  Created by Andy Lee on 5/8/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"
#import "AKBindingItem.h"
#import "AKCategoryToken.h"
#import "AKFrameworkConstants.h"
#import "AKDevToolsUtils.h"
#import "AKPrefUtils.h"
#import "AKClassToken.h"
#import "AKMethodItem.h"
#import "AKPropertyItem.h"
#import "AKProtocolToken.h"
#import "AKGroupItem.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"
#import "AKRegexUtils.h"
#import "DIGSLog.h"
#import "AKDocSetQuery.h"
#import "QuietLog.h"


@interface AKDatabase ()
@property (NS_NONATOMIC_IOSONLY, readwrite, copy) NSArray *frameworkNames;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSMutableDictionary *classTokensByName;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSMutableDictionary *protocolTokensByName;

- (AKDocSetQuery *)_queryWithEntityName:(NSString *)entityName;
- (NSArray *)_arrayWithTokensForLanguage:(NSString *)languageName;
@end


@interface AKDatabase (PrivateObjC)
- (void)_importObjectiveCTokens;
@end


@interface AKDatabase (PrivateC)
- (void)_importCTokens;
@end
