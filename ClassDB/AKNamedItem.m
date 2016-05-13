//
//  AKNamedItem.m
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedItem.h"

@interface AKNamedItem ()
@property (weak, readwrite) AKNamedItem *superitem;
@property (copy) NSMutableDictionary *subitemsByName;
@end

@implementation AKNamedItem

#pragma mark - Init/awake/dealloc

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subitemsByName = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Getters and setters

- (NSString *)sortName
{
    return self.name;
}

- (NSString *)displayName
{
    return self.name;
}

- (NSArray *)subitemNames
{
    return self.subitemsByName.allKeys;
}

- (NSArray *)sortedSubitemNames
{
    return [self.subitemsByName.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *)subitems
{
    return self.subitemsByName.allValues;
}

- (NSArray *)sortedSubitems
{
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"sortName" ascending:YES];
    return [self.subitems sortedArrayUsingDescriptors:@[nameSort]];
}

#pragma mark - Managing subitems

- (BOOL)hasSubitemWithName:(NSString *)name
{
    return ([self subitemWithName:name] != nil);
}

- (AKNamedItem *)subitemWithName:(NSString *)name
{
    return self.subitemsByName[name];
}

- (AKNamedItem *)addSubitemIfAbsent:(AKNamedItem *)subitem
{
    NSAssert(subitem != nil, @"Can't add nil subitem.");
    NSAssert(subitem.name != nil, @"Can't add a subitem with no name.");

    if ([self hasSubitemWithName:subitem.name]) {
        return [self subitemWithName:subitem.name];
    } else {
        self.subitemsByName[subitem.name] = subitem;
        subitem.superitem = self;
        return nil;
    }
}

@end
