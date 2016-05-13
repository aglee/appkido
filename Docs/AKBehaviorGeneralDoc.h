/*
 * AKBehaviorGeneralDoc.h
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTokenDoc.h"

@class AKBehaviorItem;

/*!
 * Abstract class that represents one of the docs under the "General" subtopic
 * of a class or protocol topic.
 *
 * self.token is an AKBehaviorItem.
 */
@interface AKBehaviorGeneralDoc : AKTokenDoc

#pragma mark - Init/awake/dealloc

/*!
 * A class can span multiple frameworks, with an AKBehaviorGeneralDoc for each
 * framework it belongs to. Pass nil for frameworkName if the doc is for the
 * class's main framework (the one that declares it). If the behavior is a
 * protocol, frameworkName should always be nil -- a protocol can only belong to
 * one framework.
 */
- (instancetype)initWithBehaviorItem:(AKBehaviorItem *)behaviorItem extraFrameworkName:(NSString *)frameworkName;

/*!
 * Used to calculate docName and stringToDisplayInDocList by "qualifying" the
 * doc name with the name of the extra framework, if there is one.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *unqualifiedDocName;

@end
