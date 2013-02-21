//
// AKBehaviorNode.m
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorNode.h"

#import "DIGSLog.h"
#import "AKProtocolNode.h"
#import "AKPropertyNode.h"
#import "AKMethodNode.h"
#import "AKCollectionOfNodes.h"

@implementation AKBehaviorNode


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName owningFramework:(AKFramework *)theFramework
{
    if ((self = [super initWithNodeName:nodeName owningFramework:theFramework]))
    {
        _protocolNodes = [[NSMutableArray alloc] init];
        _protocolNodeNames = [[NSMutableSet alloc] init];

        _indexOfProperties = [[AKCollectionOfNodes alloc] init];
        _indexOfClassMethods = [[AKCollectionOfNodes alloc] init];
        _indexOfInstanceMethods = [[AKCollectionOfNodes alloc] init];

        _allOwningFrameworks = [NSMutableArray arrayWithObject:theFramework];

        _nodeDocumentationByFrameworkName = [[NSMutableDictionary alloc] init];
    }

    return self;
}



#pragma mark -
#pragma mark Getters and setters -- general

- (NSArray *)allOwningFrameworks
{
    return _allOwningFrameworks;
}

- (BOOL)isClassNode
{
    return NO;
}

- (NSString *)headerFileWhereDeclared
{
    return _headerFileWhereDeclared;
}

- (void)setHeaderFileWhereDeclared:(NSString *)aPath
{
    _headerFileWhereDeclared = aPath;
}

- (void)addImplementedProtocol:(AKProtocolNode *)node
{
    if ([_protocolNodeNames containsObject:[node nodeName]])
    {
        DIGSLogWarning(
            @"trying to add protocol [%@] again to behavior [%@]",
            [node nodeName], [self nodeName]);
    }
    else
    {
        [_protocolNodes addObject:node];
        [_protocolNodeNames addObject:[node nodeName]];
    }
}

- (NSArray *)implementedProtocols
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:_protocolNodes];
    NSEnumerator *en = [_protocolNodes objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        [result addObjectsFromArray:[protocolNode implementedProtocols]];
    }

    return result;
}

- (AKFileSection *)nodeDocumentationForFrameworkNamed:(NSString *)frameworkName
{
    return [_nodeDocumentationByFrameworkName objectForKey:frameworkName];
}

- (void)setNodeDocumentation:(AKFileSection *)fileSection forFrameworkNamed:(NSString *)frameworkName
{
    if ((frameworkName == nil) || [frameworkName isEqualToString:[[self owningFramework] frameworkName]])
    {
        [super setNodeDocumentation:fileSection];
    }

    if (![_allOwningFrameworks containsObject:frameworkName])
    {
        [_allOwningFrameworks addObject:frameworkName];
    }

    [_nodeDocumentationByFrameworkName setObject:fileSection forKey:frameworkName];
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
    owningFramework:(AKFramework *)nodeOwningFW
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
        DIGSLogInfo(
            @"Couldn't find class method or instance method named %@ while processing deprecated methods for behavior %@",
            methodName, [self nodeName]);
    }
    else
    {
        [methodNode setIsDeprecated:YES];
    }
    
    return methodNode;
}


#pragma mark -
#pragma mark AKDatabaseNode methods

- (void)setOwningFramework:(AKFramework *)aFramework
{
    [super setOwningFramework:aFramework];

    // Move this framework name to the beginning of _allOwningFrameworks.
    if (aFramework)
    {
        [_allOwningFrameworks removeObject:aFramework];
        [_allOwningFrameworks insertObject:aFramework atIndex:0];
    }
}

- (void)setNodeDocumentation:(AKFileSection *)fileSection
{
    DIGSLogDebug(@"Unexpected: behavior node %@ getting a -setNodeDocumentation: message", [self nodeName]);
    [super setNodeDocumentation:fileSection];
    [self setNodeDocumentation:fileSection forFrameworkNamed:[[self owningFramework] frameworkName]];
}

@end
