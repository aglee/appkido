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
#import "AKProtocolItem.h"

@interface AKRandomSearch ()
@property (nonatomic, readwrite, copy) NSString *selectedAPISymbol;
@end

@implementation AKRandomSearch

@synthesize selectedAPISymbol = _selectedAPISymbol;

#pragma mark -
#pragma mark Factory methods

+ (instancetype)randomSearchWithDatabase:(AKDatabase *)db
{
    AKRandomSearch *randomSearch = [[self alloc] initWithDatabase:db];

    [randomSearch makeRandomSelection];

    return randomSearch;
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)db
{
    if ((self = [super init]))
    {
        _database = db;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithDatabase:nil];
}


#pragma mark -
#pragma mark Random selection

- (void)makeRandomSelection
{
    // Construct an array containing all the API symbols we want to choose from,
    // and a parallel array containing corresponding database nodes.
    NSMutableArray *allSymbols = [NSMutableArray array];

    [self _addClassesToSymbolArray:allSymbols];
    [self _addClassMembersToSymbolArray:allSymbols];
    [self _addProtocolsToSymbolArray:allSymbols];
    [self _addProtocolMembersToSymbolArray:allSymbols];
    [self _addFunctionsToSymbolArray:allSymbols];
    [self _addGlobalsToSymbolArray:allSymbols];

    // Make a random selection.
    NSUInteger randomArrayIndex = (arc4random() % allSymbols.count);

    self.selectedAPISymbol = allSymbols[randomArrayIndex];
}

#pragma mark -
#pragma mark Private methods

- (void)_addNodes:(NSArray *)nodesToAdd toSymbolArray:(NSMutableArray *)apiSymbols
{
    for (AKDocSetTokenItem *node in nodesToAdd)
    {
        [apiSymbols addObject:node.nodeName];
    }
}

- (void)_addClassesToSymbolArray:(NSMutableArray *)apiSymbols
{
    [self _addNodes:[_database allClasses] toSymbolArray:apiSymbols];
}

- (void)_addClassMembersToSymbolArray:(NSMutableArray *)apiSymbols
{
    for (AKClassNode *classNode in [_database allClasses])
    {
        [self _addNodes:[classNode documentedProperties] toSymbolArray:apiSymbols];
        [self _addNodes:[classNode documentedClassMethods] toSymbolArray:apiSymbols];
        [self _addNodes:[classNode documentedInstanceMethods] toSymbolArray:apiSymbols];
        [self _addNodes:[classNode documentedDelegateMethods] toSymbolArray:apiSymbols];
        [self _addNodes:[classNode documentedNotifications] toSymbolArray:apiSymbols];
    }
}

- (void)_addProtocolsToSymbolArray:(NSMutableArray *)apiSymbols
{
    [self _addNodes:[_database allProtocols] toSymbolArray:apiSymbols];
}

- (void)_addProtocolMembersToSymbolArray:(NSMutableArray *)apiSymbols
{
    for (AKProtocolItem *protocolItem in [_database allProtocols])
    {
        [self _addNodes:[protocolItem documentedProperties] toSymbolArray:apiSymbols];
        [self _addNodes:[protocolItem documentedClassMethods] toSymbolArray:apiSymbols];
        [self _addNodes:[protocolItem documentedInstanceMethods] toSymbolArray:apiSymbols];
    }
}

- (void)_addFunctionsToSymbolArray:(NSMutableArray *)apiSymbols
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupNode *groupNode in [_database functionsGroupsForFrameworkNamed:fwName])
        {
            [self _addNodes:[groupNode subitems] toSymbolArray:apiSymbols];
        }
    }
}

- (void)_addGlobalsToSymbolArray:(NSMutableArray *)apiSymbols
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupNode *groupNode in [_database globalsGroupsForFrameworkNamed:fwName])
        {
            for (AKGlobalsNode *globalsNode in [groupNode subitems])
            {
                [apiSymbols addObjectsFromArray:[globalsNode namesOfGlobals]];
            }
        }
    }
}

@end
