//
//  AKRegexUtils.m
//  AppKiDo
//
//  Created by Andy Lee on 5/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKRegexUtils.h"
#import "AKResult.h"

@implementation AKRegexUtils

+ (AKResult *)constructRegexWithPattern:(NSString *)pattern
{
	// Remove leading and trailing whitespace from the pattern.
	pattern = [pattern stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	// Interpret any internal whitespace in the pattern as "non-empty whitespace of any length".
	pattern = [self _makeAllWhitespaceStretchyInPattern:pattern];

	// Expand %...% placeholders.  Note that we replace %keypath% BEFORE replacing %ident%, because the expansion of %keypath% contains "%ident%".
	pattern = [pattern stringByReplacingOccurrencesOfString:@"%keypath%"
												 withString:@"(?:(?:%ident%(?:\\.%ident%)*)(?:\\.@count)?)"];
	pattern = [pattern stringByReplacingOccurrencesOfString:@"%ident%"
												 withString:@"(?:[_A-Za-z][_0-9A-Za-z]*)"];
	pattern = [pattern stringByReplacingOccurrencesOfString:@"%lit%"
												 withString:@"(?:(?:[^\"]|(?:\\\"))*)"];

	// Try to construct the NSRegularExpression object.
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
																		   options:0
																			 error:&error];
	return (regex
			? [AKResult successResultWithObject:regex]
			: [AKResult failureResultWithError:error]);
}

+ (AKResult *)matchRegex:(NSRegularExpression *)regex toEntireString:(NSString *)inputString
{
	// Remove leading and trailing whitespace from the input string.
	inputString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (inputString.length == 0) {
		return [AKResult failureResultWithErrorDomain:self.className
												 code:0
										  description:@"The pattern string can't be empty or blank."];
	}

	// Try to match the regex.
	NSRange rangeOfEntireString = NSMakeRange(0, inputString.length);
	NSTextCheckingResult *matchResult = [regex firstMatchInString:inputString options:0 range:rangeOfEntireString];
	if (matchResult == nil) {
		return [AKResult failureResultWithErrorDomain:self.className
												 code:0
										  description:@"Failed to match the regex."];
	} else if (!NSEqualRanges(matchResult.range, rangeOfEntireString)) {
		return [AKResult failureResultWithErrorDomain:self.className
												 code:0
										  description:@"The regex did not match the entire string."];
	}

	// Collect all the capture groups that were matched.  We start iterating at 1 because the zeroeth capture group is the entire matching string.
	NSMutableDictionary *captureGroupsByIndex = [NSMutableDictionary dictionary];
	for (NSUInteger rangeIndex = 1; rangeIndex < matchResult.numberOfRanges; rangeIndex++) {
		NSRange captureGroupRange = [matchResult rangeAtIndex:rangeIndex];
		if (captureGroupRange.location != NSNotFound) {
			captureGroupsByIndex[@(rangeIndex)] = [inputString substringWithRange:captureGroupRange];
		}
	}
//	QLog(@"parse result: %@", captureGroupsByIndex);
//	[[captureGroupsByIndex.allKeys sortedArrayUsingSelector:@selector(compare:)] enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//		QLog(@"    @%@: [%@]", obj, captureGroupsByIndex[obj]);
//	}];

	return [AKResult successResultWithObject:captureGroupsByIndex];
}

+ (AKResult *)matchPattern:(NSString *)pattern toEntireString:(NSString *)inputString
{
	AKResult *result = [self constructRegexWithPattern:pattern];
	if (result.error) {
		return result;
	}
	return [self matchRegex:result.object toEntireString:inputString];
}

#pragma mark - Private methods

+ (NSString *)_makeAllWhitespaceStretchyInPattern:(NSString *)pattern
{
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:NULL];
	pattern = [regex stringByReplacingMatchesInString:pattern options:0 range:NSMakeRange(0, pattern.length) withTemplate:@"(?:\\\\s+)"];
	return pattern;
}

@end
