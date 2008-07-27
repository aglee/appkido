/*
 * AKMethodsSubtopic.m
 *
 * Created by Andy Lee on Tue Jul 09 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKMethodsSubtopic.h"

#import <DIGSLog.h>

#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKMethodNode.h"
#import "AKMethodDoc.h"

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKMethodsSubtopic (Private)
- (NSArray *)_ancestorNodesWeCareAbout;
- (NSDictionary *)_subtopicMethodsByName;
@end


@implementation AKMethodsSubtopic

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initIncludingAncestors:(BOOL)includeAncestors
{
    if ((self = [super init]))
    {
        _includesAncestors = includeAncestors;
    }

    return self;
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (BOOL)includesAncestors
{
    return _includesAncestors;
}

- (AKBehaviorNode *)behaviorNode
{
    DIGSLogMissingOverride();
    return nil;
}

- (NSArray *)methodNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    DIGSLogMissingOverride();
    return nil;
}

+ (id)methodDocClass
{
    DIGSLogMissingOverride();
    return nil;
}

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

- (void)populateDocList:(NSMutableArray *)docList
{
    // Get method nodes for all the methods we want to list.
    NSDictionary *methodNodesByName = [self _subtopicMethodsByName];

    // Create an AKMethodDoc instance for each method we want to list.
    Class methodClass = [[self class] methodDocClass];
    NSArray *sortedMethodNames =
        [[methodNodesByName allKeys]
            sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSEnumerator *methodNamesEnum = [sortedMethodNames objectEnumerator];
    NSString *methodName;

    while ((methodName = [methodNamesEnum nextObject]))
    {
        AKMethodNode *methodNode =
            [methodNodesByName objectForKey:methodName];

        AKMethodDoc *methodDoc =
            [[[methodClass alloc]
                initWithMethodNode:methodNode
                inheritedByBehavior:[self behaviorNode]]
                autorelease];

        [docList addObject:methodDoc];
    }
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKMethodsSubtopic (Private)

- (NSArray *)_ancestorNodesWeCareAbout
{
    if (![self behaviorNode])
    {
        return [NSArray array];
    }

    // Get a list of all behaviors that declare methods we want to list.
    NSMutableArray *ancestorNodes =
        [NSMutableArray arrayWithObject:[self behaviorNode]];

    if (_includesAncestors)
    {
        // Add superclasses to the list.  We will check nearest
        // superclasses first.
        if ([[self behaviorNode] isClassNode])
        {
            AKClassNode *classNode = (AKClassNode *)[self behaviorNode];

            while ((classNode = [classNode parentClass]))
            {
                [ancestorNodes addObject:classNode];
            }
        }

        // Add protocols we conform to to the list.  They will
        // be the last behaviors we check.
        [ancestorNodes
            addObjectsFromArray:
                [[self behaviorNode] implementedProtocols]];
    }

    return ancestorNodes;
}

- (NSDictionary *)_subtopicMethodsByName
{
    // Get a list of all behaviors that declare methods we want to
    // include in our doc list.
    NSArray *ancestorNodes = [self _ancestorNodesWeCareAbout];

    // Match each inherited method name to the ancestor we get it from.
    // Because of the order in which we traverse ancestors, the
    // the *earliest* ancestor that implements each method is what will
    // remain in the dictionary.
    NSMutableDictionary *methodsByName = [NSMutableDictionary dictionary];
    NSEnumerator *ancestorEnum = [ancestorNodes objectEnumerator];
    AKBehaviorNode *ancestorNode;

    while ((ancestorNode = [ancestorEnum nextObject]) != nil)
    {
        NSEnumerator *methodNodeEnum =
            [[self methodNodesForBehavior:ancestorNode] objectEnumerator];
        AKMethodNode *methodNode;

        while ((methodNode = [methodNodeEnum nextObject]) != nil)
        {
            [methodsByName
                setObject:methodNode
                forKey:[methodNode nodeName]];
        }
    }

    return methodsByName;
}

@end
