/*
 * AKMemberDoc.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKMemberDoc.h"

#import "DIGSLog.h"

#import "AKFrameworkConstants.h"
#import "AKProtocolNode.h"
#import "AKMemberNode.h"

@implementation AKMemberDoc


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithMemberNode:(AKMemberNode *)memberNode
    inheritedByBehavior:(AKBehaviorNode *)behaviorNode
{
    if ((self = [super init]))
    {
        _memberNode = memberNode;
        _behaviorNode = behaviorNode;
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}



#pragma mark -
#pragma mark Manipulating node names

+ (NSString *)punctuateNodeName:(NSString *)memberName
{
    DIGSLogError_MissingOverride();
    return nil;
}


#pragma mark -
#pragma mark AKDoc methods

- (AKFileSection *)fileSection
{
    return [_memberNode nodeDocumentation];
}

- (NSString *)stringToDisplayInDocList
{
    NSString *displayString = [[self class] punctuateNodeName:[self docName]];
    AKBehaviorNode *owningBehavior = [_memberNode owningBehavior];

    // Qualify the member name with ancestor or protocol info if any.
    if (_behaviorNode != owningBehavior)
    {
        if ([owningBehavior isClassNode])
        {
            // We inherited this member from an ancestor class.
            displayString =
                [NSString stringWithFormat:@"%@ (%@)", displayString, [owningBehavior nodeName]];
        }
        else
        {
            // This member is a method we implement in order to conform to
            // a protocol.
            displayString =
                [NSString stringWithFormat:@"%@ <%@>", displayString, [owningBehavior nodeName]];
        }
    }

    // If this is a method that is added by a framework that is not the class's
    // main framework, show that.
    NSString *memberFrameworkName = [_memberNode owningFrameworkName];
    BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:[_behaviorNode owningFrameworkName]];

    if (!memberIsInSameFramework)
    {
        displayString = [NSString stringWithFormat:@"%@ [%@]", displayString, memberFrameworkName];
    }
    
    // In the Feb 2007 docs (maybe earlier?), deprecated methods are documented
    // separately, so it's possible for us to know which methods are deprecated,
    // assuming the docs are accurate.
    //
    // If we know the method is deprecated, show that.
    if ([_memberNode isDeprecated])
    {
        displayString = [NSString stringWithFormat:@"%@ (deprecated)", displayString];
    }
    
    // All done.
    return displayString;
}

// This implementation of -commentString assumes the receiver represents a
// method.  Subclasses of AKMemberDoc for which this is not true need to
// override this method.
- (NSString *)commentString
{
    NSString *memberFrameworkName = [_memberNode owningFrameworkName];
    BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:[_behaviorNode owningFrameworkName]];
    AKBehaviorNode *owningBehavior = [_memberNode owningBehavior];

    if (_behaviorNode == owningBehavior)
    {
        // We're the first class/protocol to declare this method.
        if (memberIsInSameFramework)
        {
            return @"";
        }
        else
        {
            return [NSString stringWithFormat:@"This method is added by a category in %@.",
                    memberFrameworkName];
        }
    }
    else if ([owningBehavior isClassNode])
    {
        // We inherited this method from an ancestor class.
        if (memberIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This method is inherited from class %@.",
                    [owningBehavior nodeName]];
        }
        else
        {
            return [NSString stringWithFormat:@"This method is inherited from %@ class %@.",
                    memberFrameworkName, [owningBehavior nodeName]];
        }
    }
    else
    {
        // We implement this method in order to conform to a protocol.
        if (memberIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This method is declared in protocol <%@>.",
                    [owningBehavior nodeName]];
        }
        else
        {
            return [NSString stringWithFormat:@"This method is declared in %@ protocol <%@>.",
                    memberFrameworkName, [owningBehavior nodeName]];
        }
    }
}


@end
