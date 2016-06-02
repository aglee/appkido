/*
 * AKHeaderFileDoc.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNamedObject.h"
#import "AKDoc.h"

@class AKToken;

extern NSString *AKHeaderFileDocName;

/*!
 * Displays the header file in which the token is declared, if we know it.
 */
@interface AKHeaderFileDoc : AKNamedObject <AKDoc>

@property (strong) AKToken *token;

- (instancetype)initWithToken:(AKToken *)token NS_DESIGNATED_INITIALIZER;

@end
