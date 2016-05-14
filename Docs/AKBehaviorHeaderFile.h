/*
 * AKBehaviorHeaderFile.m
 *
 * Created by Andy Lee on Tue Mar 16 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNamedObject.h"

@class AKBehaviorToken;

extern NSString *AKBehaviorHeaderFileName;

/*!
 * Represents the "Header File" doc under a class or protocol's "General"
 * subtopic.
 */
@interface AKBehaviorHeaderFile : AKNamedObject
@property (strong) AKBehaviorToken *behaviorToken;
@end