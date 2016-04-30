//
// AKBehaviorItem.m
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorItem.h"

#import "DIGSLog.h"
#import "AKProtocolItem.h"
#import "AKPropertyItem.h"
#import "AKMethodItem.h"
#import "AKCollectionOfItems.h"

@implementation AKBehaviorItem

@synthesize headerFileWhereDeclared = _headerFileWhereDeclared;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithTokenName:(NSString *)tokenName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithTokenName:tokenName database:database frameworkName:frameworkName]))
    {
        _protocolItems = [[NSMutableArray alloc] init];
        _protocolItemNames = [[NSMutableSet alloc] init];

        _indexOfProperties = [[AKCollectionOfItems alloc] init];
        _indexOfClassMethods = [[AKCollectionOfItems alloc] init];
        _indexOfInstanceMethods = [[AKCollectionOfItems alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Getters and setters -- general

- (BOOL)isClassItem
{
    return NO;
}

- (void)addImplementedProtocol:(AKProtocolItem *)protocolItem
{
    if ([_protocolItemNames containsObject:protocolItem.tokenName])
    {
        // I've seen this happen when a .h contains two declarations of a
        // protocol in different #if branches. Example: NSURL.
        DIGSLogDebug(@"trying to add protocol [%@] again to behavior [%@]",
                     [protocolItem tokenName], [self tokenName]);
    }
    else
    {
        [_protocolItems addObject:protocolItem];
        [_protocolItemNames addObject:protocolItem.tokenName];
    }
}

- (void)addImplementedProtocols:(NSArray *)protocolItems
{
    for (AKProtocolItem *protocolItem in protocolItems)
    {
        [self addImplementedProtocol:protocolItem];
    }
}

- (NSArray *)implementedProtocols
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:_protocolItems];

    for (AKProtocolItem *protocolItem in _protocolItems)
    {
        if (protocolItem != self) {
            [result addObjectsFromArray:[protocolItem implementedProtocols]];
        }
    }

    return result;
}

- (NSArray *)instanceMethodItems
{
    return [_indexOfInstanceMethods allNodes];
}

#pragma mark -
#pragma mark Getters and setters -- properties

- (NSArray *)documentedProperties
{
    return [_indexOfProperties nodesWithDocumentation];
}

- (AKPropertyItem *)propertyNodeWithName:(NSString *)propertyName
{
    return (AKPropertyItem *)[_indexOfProperties itemWithTokenName:propertyName];
}

- (void)addPropertyNode:(AKPropertyItem *)propertyNode
{
    [_indexOfProperties addNode:propertyNode];
}

#pragma mark -
#pragma mark Getters and setters -- class methods

- (NSArray *)documentedClassMethods
{
    return [_indexOfClassMethods nodesWithDocumentation];
}

- (AKMethodItem *)classMethodWithName:(NSString *)methodName
{
    return (AKMethodItem *)[_indexOfClassMethods itemWithTokenName:methodName];
}

- (void)addClassMethod:(AKMethodItem *)methodItem
{
    [_indexOfClassMethods addNode:methodItem];
}

#pragma mark -
#pragma mark Getters and setters -- instance methods

- (NSArray *)documentedInstanceMethods
{
    return [_indexOfInstanceMethods nodesWithDocumentation];
}

- (AKMethodItem *)instanceMethodWithName:(NSString *)methodName
{
    return (AKMethodItem *)[_indexOfInstanceMethods itemWithTokenName:methodName];
}

- (void)addInstanceMethod:(AKMethodItem *)methodItem
{
    [_indexOfInstanceMethods addNode:methodItem];
}

#pragma mark -
#pragma mark Getters and setters -- deprecated methods

- (AKMethodItem *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
                                        frameworkName:(NSString *)frameworkName
{
    // Is this an instance method or a class method?  Note this assumes a
    // a method node for the method already exists, presumably because we
    // parsed the header files.
    AKMethodItem *methodItem = [self classMethodWithName:methodName];
    
    if (methodItem == nil)
    {
        methodItem = [self instanceMethodWithName:methodName];
    }
    
    if (methodItem == nil)
    {
        DIGSLogInfo(@"Couldn't find class method or instance method named %@"
                    @" while processing deprecated methods for behavior %@",
                    methodName, [self tokenName]);
    }
    else
    {
        [methodItem setIsDeprecated:YES];
    }
    
    return methodItem;
}

@end
