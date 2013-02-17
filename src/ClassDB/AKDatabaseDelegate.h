//
//  AKDatabaseDelegate.h
//  AppKiDo
//
//  Created by Andy Lee on 2/16/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKDatabase;

@protocol AKDatabaseDelegate
@optional
- (void)database:(AKDatabase *)database willLoadTokensForFramework:(NSString *)frameworkName;
@end


