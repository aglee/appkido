/*
 * AKMethodDoc.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKMethodDoc.h"

#import <DIGSLog.h>

#import "AKFrameworkConstants.h"
#import "AKProtocolNode.h"
#import "AKMethodNode.h"
#import "AKMethodsSubtopic.h"

@implementation AKMethodDoc

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithMethodNode:(AKMethodNode *)methodNode
    inheritedByBehavior:(AKBehaviorNode *)behaviorNode
{
    if ((self = [super init]))
    {
        _methodNode = [methodNode retain];
        _behaviorNode = [behaviorNode retain];
    }

    return self;
}

- (id)init
{
    DIGSLogNondesignatedInitializer();
    [self dealloc];
    return nil;
}

- (void)dealloc
{
    [_methodNode release];
    [_behaviorNode release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (AKMethodNode *)docMethodNode
{
    return _methodNode;
}

//-------------------------------------------------------------------------
// Manipulating method names
//-------------------------------------------------------------------------

+ (NSString *)punctuateMethodName:(NSString *)methodName
{
    DIGSLogMissingOverride();
    return nil;
}

//-------------------------------------------------------------------------
// AKDoc methods
//-------------------------------------------------------------------------

- (AKFileSection *)fileSection
{
    return [_methodNode nodeDocumentation];
}

- (NSString *)stringToDisplayInDocList
{
    NSString *displayString =
        [[self class] punctuateMethodName:[self docName]];
    AKBehaviorNode *ownerOfMethod = [_methodNode owningBehavior];

    // Qualify the method name with ancestor or protocol info if any.
    if (_behaviorNode != ownerOfMethod)
    {
        if ([ownerOfMethod isClassNode])
        {
            // We inherited this method from an ancestor class.
            displayString =
                [NSString stringWithFormat:@"%@ (%@)",
                    displayString,
                    [ownerOfMethod nodeName]];
        }
        else
        {
            // We implement this method in order to conform to a protocol.
            displayString =
                [NSString stringWithFormat:@"%@ <%@>",
                    displayString,
                    [ownerOfMethod nodeName]];
        }
    }

    // If the method is added by a framework that is not the class's
    // main framework, show that.
    NSString *methodFrameworkName = [_methodNode owningFramework];
    BOOL methodIsInSameFramework = 
        [methodFrameworkName
            isEqualToString:[_behaviorNode owningFramework]];

    if (!methodIsInSameFramework)
    {
        displayString =
            [NSString stringWithFormat:@"%@ [%@]",
                displayString,
                methodFrameworkName];
    }
    
    // In the Feb 2007 docs (maybe earlier?), deprecated methods are documented
    // separately, so it's possible for us to know which methods are deprecated,
    // assuming the docs are accurate.
    //
    // If we know the method is deprecated, show that.
    if ([_methodNode isDeprecated])
    {
        displayString =
            [NSString stringWithFormat:@"%@ (deprecated)",
                displayString];
    }
    
    // All done.
    return displayString;
}

- (NSString *)commentString
{
    NSString *methodFrameworkName = [_methodNode owningFramework];
    BOOL methodIsInSameFramework = 
        [methodFrameworkName
            isEqualToString:[_behaviorNode owningFramework]];
    AKBehaviorNode *ownerOfMethod = [_methodNode owningBehavior];

    if (_behaviorNode == ownerOfMethod)
    {
        // We're the first class/protocol to declare this method.
        if (methodIsInSameFramework)
        {
            return @"";
        }
        else
        {
            return
                [NSString
                    stringWithFormat:
                        @"This method is added by a category in %@.",
                        methodFrameworkName];
        }
    }
    else if ([ownerOfMethod isClassNode])
    {
        // We inherited this method from an ancestor class.
        if (methodIsInSameFramework)
        {
            return
                [NSString stringWithFormat:
                    @"This method is inherited from class %@.",
                    [ownerOfMethod nodeName]];
        }
        else
        {
            return
                [NSString stringWithFormat:
                    @"This method is inherited from %@ class %@.",
                    methodFrameworkName,
                    [ownerOfMethod nodeName]];
        }
    }
    else
    {
        // We implement this method in order to conform to a protocol.
        if (methodIsInSameFramework)
        {
            return
                [NSString stringWithFormat:
                    @"This method is declared in protocol <%@>.",
                    [ownerOfMethod nodeName]];
        }
        else
        {
            return
                [NSString stringWithFormat:
                    @"This method is declared in %@ protocol <%@>.",
                    methodFrameworkName,
                    [ownerOfMethod nodeName]];
        }
    }
}

@end
