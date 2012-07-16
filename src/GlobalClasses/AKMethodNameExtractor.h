//
//  AKMethodNameExtractor.h
//  AppKiDo
//
//  Created by Andy Lee on 7/14/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Look for top-level xxx:'s. 
 *
 * Everything else is either delimited -- as in (), [] -- or comments.
 */
@interface AKMethodNameExtractor : NSObject


- (id)initWithString:(NSString *)string;

+ (NSString *)extractMethodNameFromString:(NSString *)string;
- (NSString *)extractMethodName;

@end
