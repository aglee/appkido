/*
 * AKGroupNode.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGroupNode.h"

#import "AKSortUtils.h"

@implementation AKGroupNode

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithNodeName:nodeName database:database frameworkName:frameworkName]))
    {
        _subitems = [[NSMutableArray alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Getters and setters

- (void)addSubitem:(AKDocSetTokenItem *)item
{
    [_subitems addObject:item];
}

- (NSInteger)numberOfSubitems
{
    return _subitems.count;
}

- (NSArray *)subitems
{
    return _subitems;
}

- (AKDocSetTokenItem *)subitemWithName:(NSString *)nodeName
{
    for (AKDocSetTokenItem *subitem in _subitems)
    {
        if ([subitem.nodeName isEqualToString:nodeName])
        {
            return subitem;
        }
    }

    // If we got this far, the search failed.
    return nil;
}

@end
