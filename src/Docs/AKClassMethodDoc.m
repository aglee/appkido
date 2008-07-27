/*
 * AKClassMethodDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassMethodDoc.h"

#import "AKBehaviorNode.h"

@implementation AKClassMethodDoc

//-------------------------------------------------------------------------
// AKMethodDoc methods
//-------------------------------------------------------------------------

+ (NSString *)punctuateMethodName:(NSString *)methodName
{
    return [@"+" stringByAppendingString:methodName];
}

@end
