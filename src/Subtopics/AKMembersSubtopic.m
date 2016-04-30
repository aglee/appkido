/*
 * AKMembersSubtopic.m
 *
 * Created by Andy Lee on Tue Jul 09 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKMembersSubtopic.h"

#import "DIGSLog.h"

#import "AKClassItem.h"
#import "AKProtocolItem.h"
#import "AKMethodItem.h"
#import "AKMemberDoc.h"

@implementation AKMembersSubtopic

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initIncludingAncestors:(BOOL)includeAncestors
{
    if ((self = [super init]))
    {
        _includesAncestors = includeAncestors;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initIncludingAncestors:NO];
}

#pragma mark -
#pragma mark Getters and setters

- (BOOL)includesAncestors
{
    return _includesAncestors;
}

- (AKBehaviorItem *)behaviorItem
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSArray *)memberItemsForBehavior:(AKBehaviorItem *)behaviorItem
{
    DIGSLogError_MissingOverride();
    return nil;
}

+ (id)memberDocClass
{
    DIGSLogError_MissingOverride();
    return nil;
}

#pragma mark -
#pragma mark AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    // Get method nodes for all the methods we want to list.
    NSDictionary *methodItemsByName = [self _subtopicMethodsByName];

    // Create an AKMemberDoc instance for each method we want to list.
    Class methodClass = [[self class] memberDocClass];
    NSArray *sortedMethodNames = [methodItemsByName.allKeys
                                  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    for (NSString *methodName in sortedMethodNames)
    {
        AKMethodItem *methodItem = methodItemsByName[methodName];
        AKMemberDoc *methodDoc = [[methodClass alloc] initWithMemberItem:methodItem
                                                      inheritedByBehavior:[self behaviorItem]];
        [docList addObject:methodDoc];
    }
}

#pragma mark -
#pragma mark Private methods

// Get a list of all behaviors that declare methods we want to
// include in our doc list.
- (NSArray *)_ancestorNodesWeCareAbout
{
    if (![self behaviorItem])
    {
        return @[];
    }

    // Get a list of all behaviors that declare methods we want to list.
    NSMutableArray *ancestorNodes = [NSMutableArray arrayWithObject:[self behaviorItem]];

    if (_includesAncestors)
    {
        // Add superclasses to the list.  We will check nearest
        // superclasses first.
        if ([[self behaviorItem] isClassItem])
        {
            AKClassItem *classItem = (AKClassItem *)[self behaviorItem];

            while ((classItem = classItem.parentClass))
            {
                [ancestorNodes addObject:classItem];
            }
        }

        // Add protocols we conform to to the list.  They will
        // be the last behaviors we check.
        [ancestorNodes addObjectsFromArray:[[self behaviorItem] implementedProtocols]];
    }

    return ancestorNodes;
}

- (NSDictionary *)_subtopicMethodsByName
{
    // Match each inherited method name to the ancestor we get it from.
    // Because of the order in which we traverse ancestors, the
    // the *earliest* ancestor that implements each method is what will
    // remain in the dictionary.
    NSMutableDictionary *methodsByName = [NSMutableDictionary dictionary];

    for (AKBehaviorItem *ancestorNode in [self _ancestorNodesWeCareAbout])
    {
        for (AKMethodItem *methodItem in [self memberItemsForBehavior:ancestorNode])
        {
            methodsByName[methodItem.nodeName] = methodItem;
        }
    }

    return methodsByName;
}

@end
