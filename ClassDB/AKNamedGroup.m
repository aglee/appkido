//
//  AKNamedGroup.m
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedGroup.h"

@interface AKNamedGroup ()
@property (copy) NSMutableDictionary *itemsByName;
@end

@implementation AKNamedGroup

@dynamic itemNames;
@dynamic sortedItemNames;

#pragma mark - Init/awake/dealloc

- (instancetype)init
{
    self = [super init];
    if (self) {
        _itemsByName = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Getters and setters

- (NSArray *)itemNames
{
    return self.itemsByName.allKeys;
}

- (NSArray *)sortedItemNames
{
    return [self.itemsByName.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark - Managing the items in the group

- (BOOL)hasItemWithName:(NSString *)name
{
    return ([self itemWithName:name] != nil);
}

- (AKNamedItem *)itemWithName:(NSString *)name
{
    return self.itemsByName[name];
}

- (AKNamedItem *)addItemIfAbsent:(AKNamedItem *)item
{
    NSAssert(item != nil, @"Can't add nil item to AKNamedGroup.");
    NSAssert(item.name != nil, @"Can't add an item with no name to AKNamedGroup.");

    if ([self hasItemWithName:item.name]) {
        return [self itemWithName:item.name];
    } else {
        self.itemsByName[item.name] = item;
        return nil;
    }
}

@end
