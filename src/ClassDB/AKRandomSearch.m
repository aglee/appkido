//
//  AKRandomSearch.m
//  AppKiDo
//
//  Created by Andy Lee on 3/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKRandomSearch.h"

#import "DIGSLog.h"

#import "AKClassNode.h"
#import "AKDatabase.h"
#import "AKGlobalsNode.h"
#import "AKGroupNode.h"
#import "AKProtocolNode.h"

@implementation AKRandomSearch

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDatabase:(AKDatabase *)db
{
    if ((self = [super init]))
    {
        _database = [db retain];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}

- (void)dealloc
{
    [_database release];

    [super dealloc];
}

#pragma mark -
#pragma mark Random selection

- (NSString *)randomAPISymbol
{
    // Make one huge array of symbols and pick one.
    NSMutableArray *allSymbols = [NSMutableArray array];

    [self _addClassNamesToArray:allSymbols];
    [self _addClassMemberNamesToArray:allSymbols];
    [self _addProtocolNamesToArray:allSymbols];
    [self _addProtocolMemberNamesToArray:allSymbols];
    [self _addFunctionNamesToArray:allSymbols];
    [self _addNamesOfGlobalsToArray:allSymbols];

    return [allSymbols objectAtIndex:(arc4random() % [allSymbols count])];
}

#pragma mark -
#pragma mark Private methods

- (void)_addNamesOfNodes:(NSArray *)databaseNodes toArray:(NSMutableArray *)array
{
    for (AKDatabaseNode *node in databaseNodes)
    {
        [array addObject:[node nodeName]];
    }
}

- (void)_addClassNamesToArray:(NSMutableArray *)array
{
    [self _addNamesOfNodes:[_database allClasses] toArray:array];
}

- (void)_addClassMemberNamesToArray:(NSMutableArray *)array
{
    for (AKClassNode *classNode in [_database allClasses])
    {
        [self _addNamesOfNodes:[classNode documentedProperties] toArray:array];
        [self _addNamesOfNodes:[classNode documentedClassMethods] toArray:array];
        [self _addNamesOfNodes:[classNode documentedInstanceMethods] toArray:array];
        [self _addNamesOfNodes:[classNode documentedDelegateMethods] toArray:array];
        [self _addNamesOfNodes:[classNode documentedNotifications] toArray:array];
    }
}

- (void)_addProtocolNamesToArray:(NSMutableArray *)array
{
    [self _addNamesOfNodes:[_database allProtocols] toArray:array];
}

- (void)_addProtocolMemberNamesToArray:(NSMutableArray *)array
{
    for (AKProtocolNode *protocolNode in [_database allProtocols])
    {
        [self _addNamesOfNodes:[protocolNode documentedProperties] toArray:array];
        [self _addNamesOfNodes:[protocolNode documentedClassMethods] toArray:array];
        [self _addNamesOfNodes:[protocolNode documentedInstanceMethods] toArray:array];
    }
}

- (void)_addFunctionNamesToArray:(NSMutableArray *)array
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupNode *groupNode in [_database functionsGroupsForFrameworkNamed:fwName])
        {
            [self _addNamesOfNodes:[groupNode subnodes] toArray:array];
        }
    }
}

- (void)_addNamesOfGlobalsToArray:(NSMutableArray *)array
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupNode *groupNode in [_database globalsGroupsForFrameworkNamed:fwName])
        {
            for (AKGlobalsNode *globalsNode in [groupNode subnodes])
            {
                [array addObjectsFromArray:[globalsNode namesOfGlobals]];
            }
        }
    }
}

@end
