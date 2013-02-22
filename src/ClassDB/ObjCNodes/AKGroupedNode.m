//
//  AKGroupedNode.m
//  AppKiDo
//
//  Created by Andy Lee on 4/25/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKGroupedNode.h"

#import "DIGSLog.h"

@implementation AKGroupedNode

@synthesize groupName = _groupName;

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
             groupName:(NSString *)groupName
{
    if ((self = [super initWithNodeName:nodeName database:database frameworkName:frameworkName]))
    {
        _groupName = groupName;
    }

    return self;
}

- (id)initWithNodeName:(NSString *)nodeName database:database frameworkName:(NSString *)frameworkName
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark Getters and setters

- (NSString *)groupName
{
    return _groupName;
}

@end
