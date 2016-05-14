/*
 * AKBehaviorHeaderFile.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNamedObject.h"
#import "AKDocListItem.h"

@class AKBehaviorToken;

extern NSString *AKBehaviorHeaderFileName;

/*!
 * Provides the URL for the header file in which a token is declared, if there is one.
 */
@interface AKBehaviorHeaderFile : AKNamedObject <AKDocListItem>
@property (strong) AKBehaviorToken *behaviorToken;
@end
