//
//  AKFrameworkRelatedTopic.h
//  AppKiDo
//
//  Created by Andy Lee on 5/20/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKTopic.h"

@class AKFramework;

/*!
 * A topic that relates to an AKFramework in some way.
 */
@interface AKFrameworkRelatedTopic : AKTopic

@property (copy, readonly) AKFramework *framework;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(AKFramework *)framework NS_DESIGNATED_INITIALIZER;

@end
