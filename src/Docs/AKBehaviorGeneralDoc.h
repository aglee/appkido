/*
 * AKBehaviorGeneralDoc.h
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFileSectionDoc.h"

/*!
 * Abstract class that represents one of the docs under the "General" subtopic
 * of a class or protocol topic.
 */
@interface AKBehaviorGeneralDoc : AKFileSectionDoc
{
@private
    NSString *_extraFrameworkName;
}

#pragma mark -
#pragma mark Init/awake/dealloc

/*!
 * Designated initializer. It's also okay to use initWithFileSection:, which
 * calls this with nil for frameworkName.
 *
 * A class can span multiple frameworks, with an AKBehaviorGeneralDoc for each
 * framework it belongs to. Pass nil for frameworkName if the doc is for the
 * class's main framework (the one that declares it). If the behavior is a
 * protocol, frameworkName should always be nil -- a protocol can only belong to
 * one framework.
 */
- (instancetype)initWithFileSection:(AKFileSection *)fileSection
       extraFrameworkName:(NSString *)frameworkName NS_DESIGNATED_INITIALIZER;

#pragma mark -
#pragma mark Doc name

/*!
 * Used to calculate docName and stringToDisplayInDocList by "qualifying" the
 * doc name with the name of the extra framework, if there is one.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *unqualifiedDocName;

@end
