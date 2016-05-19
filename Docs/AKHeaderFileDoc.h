/*
 * AKHeaderFileDoc.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNamedObject.h"
#import "AKDoc.h"

@class AKBehaviorToken;

extern NSString *AKHeaderFileDocName;

/*!
 * Provides the URL for the header file in which a token is declared, if there is one.
 */
@interface AKHeaderFileDoc : AKNamedObject <AKDoc>

@property (strong) AKBehaviorToken *behaviorToken;

- (instancetype)initWithBehaviorToken:(AKBehaviorToken *)behaviorToken NS_DESIGNATED_INITIALIZER;

@end
