//
//  AKArrayAssortment.m
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKArrayAssortment.h"

@interface AKArrayAssortment ()
@property (strong) NSMutableDictionary *arraysByName;
@end

@implementation AKArrayAssortment

- (instancetype)init
{
	self = [super init];
	if (self) {
		_arraysByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (NSArray *)arrayNames
{
	return self.arraysByName.allKeys;
}

- (void)addObject:(id)obj toArrayWithName:(NSString *)name
{
	NSMutableArray *array = self.arraysByName[name];
	if (array == nil) {
		array = [NSMutableArray array];
		self.arraysByName[name] = array;
	}
	[array addObject:obj];
}

- (NSArray *)arrayWithName:(NSString *)name
{
	return self.arraysByName[name];
}

@end

