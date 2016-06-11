//
//  AKInferredFrameworkInfo.h
//  AppKiDo
//
//  Created by Andy Lee on 6/11/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DSAToken;

/*!
 * Tries to infer what framework tokenMO belongs to, and what the relevant
 * framework child topic is, if any.
 */
@interface AKInferredFrameworkInfo : NSObject

@property (strong, readonly) DSAToken *tokenMO;

/*! For "Foundation Constants Reference" this would be "Foundation". */
@property (copy) NSString *frameworkName;

/*! For "Foundation Constants Reference" this would be "Constants". */
@property (copy, readonly) NSString *frameworkChildTopicName;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO NS_DESIGNATED_INITIALIZER;

@end
