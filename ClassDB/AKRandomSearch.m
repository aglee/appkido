//
//  AKRandomSearch.m
//  AppKiDo
//
//  Created by Andy Lee on 3/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKRandomSearch.h"

#import "DIGSLog.h"

#import "AKClassToken.h"
#import "AKDatabase.h"
#import "AKGlobalsItem.h"
#import "AKGroupItem.h"
#import "AKProtocolToken.h"

@interface AKRandomSearch ()
@property (nonatomic, readwrite, copy) NSString *selectedAPISymbol;
@end

@implementation AKRandomSearch

@synthesize selectedAPISymbol = _selectedAPISymbol;

#pragma mark - Factory methods

+ (instancetype)randomSearchWithDatabase:(AKDatabase *)db
{
    AKRandomSearch *randomSearch = [[self alloc] initWithDatabase:db];

    [randomSearch makeRandomSelection];

    return randomSearch;
}

#pragma mark - Init/awake/dealloc

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


#pragma mark - Random selection

- (void)makeRandomSelection
{
    // Construct an array containing all the API symbols we want to choose from,
    // and a parallel array containing corresponding database items.
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

#pragma mark - Private methods

- (void)_addTokens:(NSArray *)itemsToAdd toSymbolArray:(NSMutableArray *)apiSymbols
{
    for (AKToken *item in itemsToAdd)
    {
        [apiSymbols addObject:item.tokenName];
    }
}

- (void)_addClassesToSymbolArray:(NSMutableArray *)apiSymbols
{
    [self _addTokens:[_database allClasses] toSymbolArray:apiSymbols];
}

- (void)_addClassMembersToSymbolArray:(NSMutableArray *)apiSymbols
{
    for (AKClassToken *classToken in [_database allClasses])
    {
        [self _addTokens:[classToken propertyItems] toSymbolArray:apiSymbols];
        [self _addTokens:[classToken classMethodItems] toSymbolArray:apiSymbols];
        [self _addTokens:[classToken instanceMethodItems] toSymbolArray:apiSymbols];
        [self _addTokens:[classToken documentedDelegateMethods] toSymbolArray:apiSymbols];
        [self _addTokens:[classToken documentedNotifications] toSymbolArray:apiSymbols];
    }
}

- (void)_addProtocolsToSymbolArray:(NSMutableArray *)apiSymbols
{
    [self _addTokens:[_database allProtocols] toSymbolArray:apiSymbols];
}

- (void)_addProtocolMembersToSymbolArray:(NSMutableArray *)apiSymbols
{
    for (AKProtocolToken *protocolToken in [_database allProtocols])
    {
        [self _addTokens:[protocolToken propertyItems] toSymbolArray:apiSymbols];
        [self _addTokens:[protocolToken classMethodItems] toSymbolArray:apiSymbols];
        [self _addTokens:[protocolToken instanceMethodItems] toSymbolArray:apiSymbols];
    }
}

- (void)_addFunctionsToSymbolArray:(NSMutableArray *)apiSymbols
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupItem *groupItem in [_database functionsGroupsForFramework:fwName])
        {
            [self _addTokens:[groupItem subitems] toSymbolArray:apiSymbols];
        }
    }
}

- (void)_addGlobalsToSymbolArray:(NSMutableArray *)apiSymbols
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupItem *groupItem in [_database globalsGroupsForFramework:fwName])
        {
            for (AKGlobalsItem *globalsItem in [groupItem subitems])
            {
                [apiSymbols addObjectsFromArray:[globalsItem namesOfGlobals]];
            }
        }
    }
}

@end
