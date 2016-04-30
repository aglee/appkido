//
// AKBehaviorItem.m
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorItem.h"

#import "DIGSLog.h"
#import "AKProtocolItem.h"
#import "AKPropertyNode.h"
#import "AKMethodNode.h"
#import "AKCollectionOfNodes.h"

@implementation AKBehaviorItem

@synthesize headerFileWhereDeclared = _headerFileWhereDeclared;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNodeName:(NSString *)nodeName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithNodeName:nodeName database:database frameworkName:frameworkName]))
    {
        _protocolItems = [[NSMutableArray alloc] init];
        _protocolItemNames = [[NSMutableSet alloc] init];

        _indexOfProperties = [[AKCollectionOfNodes alloc] init];
        _indexOfClassMethods = [[AKCollectionOfNodes alloc] init];
        _indexOfInstanceMethods = [[AKCollectionOfNodes alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Getters and setters -- general

- (BOOL)isClassNode
{
    return NO;
}

- (void)addImplementedProtocol:(AKProtocolItem *)protocolItem
{
    if ([_protocolItemNames containsObject:protocolItem.nodeName])
    {
        // I've seen this happen when a .h contains two declarations of a
        // protocol in different #if branches. Example: NSURL.
        DIGSLogDebug(@"trying to add protocol [%@] again to behavior [%@]",
                     [protocolItem nodeName], [self nodeName]);
    }
    else
    {
        [_protocolItems addObject:protocolItem];
        [_protocolItemNames addObject:protocolItem.nodeName];
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

- (NSArray *)instanceMethodNodes
{
    return [_indexOfInstanceMethods allNodes];
}

#pragma mark -
#pragma mark Getters and setters -- properties

- (NSArray *)documentedProperties
{
    return [_indexOfProperties nodesWithDocumentation];
}

- (AKPropertyNode *)propertyNodeWithName:(NSString *)propertyName
{
    return (AKPropertyNode *)[_indexOfProperties nodeWithName:propertyName];
}

- (void)addPropertyNode:(AKPropertyNode *)propertyNode
{
    [_indexOfProperties addNode:propertyNode];
}

#pragma mark -
#pragma mark Getters and setters -- class methods

- (NSArray *)documentedClassMethods
{
    return [_indexOfClassMethods nodesWithDocumentation];
}

- (AKMethodNode *)classMethodWithName:(NSString *)methodName
{
    return (AKMethodNode *)[_indexOfClassMethods nodeWithName:methodName];
}

- (void)addClassMethod:(AKMethodNode *)methodNode
{
    [_indexOfClassMethods addNode:methodNode];
}

#pragma mark -
#pragma mark Getters and setters -- instance methods

- (NSArray *)documentedInstanceMethods
{
    return [_indexOfInstanceMethods nodesWithDocumentation];
}

- (AKMethodNode *)instanceMethodWithName:(NSString *)methodName
{
    return (AKMethodNode *)[_indexOfInstanceMethods nodeWithName:methodName];
}

- (void)addInstanceMethod:(AKMethodNode *)methodNode
{
    [_indexOfInstanceMethods addNode:methodNode];
}

#pragma mark -
#pragma mark Getters and setters -- deprecated methods

- (AKMethodNode *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
                                        frameworkName:(NSString *)frameworkName
{
    // Is this an instance method or a class method?  Note this assumes a
    // a method node for the method already exists, presumably because we
    // parsed the header files.
    AKMethodNode *methodNode = [self classMethodWithName:methodName];
    
    if (methodNode == nil)
    {
        methodNode = [self instanceMethodWithName:methodName];
    }
    
    if (methodNode == nil)
    {
        DIGSLogInfo(@"Couldn't find class method or instance method named %@"
                    @" while processing deprecated methods for behavior %@",
                    methodName, [self nodeName]);
    }
    else
    {
        [methodNode setIsDeprecated:YES];
    }
    
    return methodNode;
}

@end
