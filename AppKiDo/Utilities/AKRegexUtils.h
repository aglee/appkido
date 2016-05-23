//
//  AKRegexUtils.h
//  AppKiDo
//
//  Created by Andy Lee on 5/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: Maybe tweak this API since I keep forgetting what to use for the key of the returned capture group dictionaries -- and forgetting the phrase "capture group".

@class AKResult;

/*
 * Replaces %ident%, %lit%, %keypath% with canned sub-patterns.
 * Ignores leading and trailing whitespace with \\s*.
 * Allows internal whitespace to be any length of any whitespace.
 * Returns dictionary with NSNumber keys indication position of capture group (1-based).
 * Returns nil if invalid pattern.
 */
@interface AKRegexUtils : NSObject

+ (AKResult *)constructRegexWithPattern:(NSString *)pattern;
+ (AKResult *)matchRegex:(NSRegularExpression *)regex toEntireString:(NSString *)inputString;
+ (AKResult *)matchPattern:(NSString *)pattern toEntireString:(NSString *)inputString;

@end
