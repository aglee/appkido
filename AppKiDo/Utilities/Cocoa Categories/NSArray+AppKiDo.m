//
//  NSArray+AppKiDo.m
//  AppKiDo
//
//  Created by Andy Lee on 5/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "NSArray+AppKiDo.h"
#import "AKClassToken.h"

static NSComparisonResult compareSortNames(NSObject<AKSortable> *left,
										   NSObject<AKSortable> *right,
										   void *context)
{
	NSComparisonResult result = [left.sortName caseInsensitiveCompare:right.sortName];
	if (result == NSOrderedSame) {
		// Put class tokens before other things with the same name.
		//TODO: Experiment with this; does it really matter if classes are sorted first?
		if ([left isKindOfClass:[AKClassToken class]]) {
			result = NSOrderedAscending;
		} else {
			result = NSOrderedDescending;
		}
	}
	return result;
}

@implementation NSArray (AppKiDo)

- (NSArray *)ak_sortedStrings
{
	return [self sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *)ak_sortedBySortName
{
	return [self sortedArrayUsingFunction:&compareSortNames context:NULL];
}

- (NSString *)ak_joinedBySpaces
{
	return [self componentsJoinedByString:@" "];
}

- (NSArray *)ak_arrayByRemovingLast:(NSInteger)numObjectsToRemove
{
	return [self subarrayWithRange:NSMakeRange(0, self.count - numObjectsToRemove)];
}

@end
