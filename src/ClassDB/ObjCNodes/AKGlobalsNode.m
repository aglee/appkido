/*
 * AKGlobalsNode.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGlobalsNode.h"

#import "AKFileSection.h"

@implementation AKGlobalsNode

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithNodeName:nodeName database:database frameworkName:frameworkName]))
    {
        _namesOfGlobals = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_namesOfGlobals release];

    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (void)addNameOfGlobal:(NSString *)nameOfGlobal
{
    [_namesOfGlobals addObject:nameOfGlobal];
}

- (NSArray *)namesOfGlobals
{
    return _namesOfGlobals;
}

@end
