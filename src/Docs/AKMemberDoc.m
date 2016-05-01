/*
 * AKMemberDoc.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKMemberDoc.h"

#import "DIGSLog.h"

#import "AKFrameworkConstants.h"
#import "AKProtocolItem.h"
#import "AKMemberItem.h"

@implementation AKMemberDoc

@synthesize memberItem = _memberItem;
@synthesize behaviorItem = _behaviorItem;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithMemberItem:(AKMemberItem *)memberItem
     inheritedByBehavior:(AKBehaviorItem *)behaviorItem
{
    if ((self = [super init]))
    {
        _memberItem = memberItem;
        _behaviorItem = behaviorItem;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithMemberItem:nil inheritedByBehavior:nil];
}


#pragma mark -
#pragma mark Manipulating token names

+ (NSString *)punctuateTokenName:(NSString *)memberName
{
    DIGSLogError_MissingOverride();
    return nil;
}

#pragma mark -
#pragma mark AKDoc methods

- (AKFileSection *)fileSection
{
    return _memberItem.tokenItemDocumentation;
}

- (NSString *)stringToDisplayInDocList
{
    NSString *displayString = [[self class] punctuateTokenName:[self docName]];
    AKBehaviorItem *owningBehavior = _memberItem.owningBehavior;

    // Qualify the member name with ancestor or protocol info if any.
    if (_behaviorItem != owningBehavior)
    {
        if ([owningBehavior isClassItem])
        {
            // We inherited this member from an ancestor class.
            displayString = [NSString stringWithFormat:@"%@ (%@)",
                             displayString, owningBehavior.tokenName];
        }
        else
        {
            // This member is a method we implement in order to conform to
            // a protocol.
            displayString = [NSString stringWithFormat:@"%@ <%@>",
                             displayString, owningBehavior.tokenName];
        }
    }

    // If this is a method that is added by a framework that is not the class's
    // main framework, show that.
    NSString *memberFrameworkName = _memberItem.nameOfOwningFramework;
    BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:_behaviorItem.nameOfOwningFramework];

    if (!memberIsInSameFramework)
    {
        displayString = [NSString stringWithFormat:@"%@ [%@]",
                         displayString, memberFrameworkName];
    }
    
    // In the Feb 2007 docs (maybe earlier?), deprecated methods are documented
    // separately, so it's possible for us to know which methods are deprecated,
    // assuming the docs are accurate.
    //
    // If we know the method is deprecated, show that.
    if (_memberItem.isDeprecated)
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
    NSString *memberFrameworkName = _memberItem.nameOfOwningFramework;
    BOOL memberIsInSameFramework = [memberFrameworkName isEqualToString:_behaviorItem.nameOfOwningFramework];
    AKBehaviorItem *owningBehavior = _memberItem.owningBehavior;

    if (_behaviorItem == owningBehavior)
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
    else if ([owningBehavior isClassItem])
    {
        // We inherited this method from an ancestor class.
        if (memberIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This method is inherited from class %@.",
                    owningBehavior.tokenName];
        }
        else
        {
            return [NSString stringWithFormat:@"This method is inherited from %@ class %@.",
                    memberFrameworkName, owningBehavior.tokenName];
        }
    }
    else
    {
        // We implement this method in order to conform to a protocol.
        if (memberIsInSameFramework)
        {
            return [NSString stringWithFormat:@"This method is declared in protocol <%@>.",
                    owningBehavior.tokenName];
        }
        else
        {
            return [NSString stringWithFormat:@"This method is declared in %@ protocol <%@>.",
                    memberFrameworkName, owningBehavior.tokenName];
        }
    }
}

@end
