//
//  NSSet+AppKiDo.m
//  AppKiDo
//
//  Created by Andy Lee on 5/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "NSSet+AppKiDo.h"
#import "NSArray+AppKiDo.h"

@implementation NSSet (AppKiDo)

- (NSArray *)ak_sortedStrings
{
	return [self.allObjects ak_sortedStrings];
}

- (NSArray *)ak_sortedBySortName
{
	return [self.allObjects ak_sortedBySortName];
}

@end
