//
//  AKRegexUtils.h
//  AppKiDo
//
//  Created by Andy Lee on 5/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKRegexUtils : NSObject

+ (NSDictionary *)matchPattern:(NSString *)pattern toEntireString:(NSString *)inputString;

@end
