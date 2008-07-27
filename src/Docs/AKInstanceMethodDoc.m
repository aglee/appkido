/*
 * AKInstanceMethodDoc.m
 *
 * Created by Andy Lee on Sun Mar 21 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKInstanceMethodDoc.h"

#import "AKBehaviorNode.h"

@implementation AKInstanceMethodDoc

//-------------------------------------------------------------------------
// AKMethodDoc methods
//-------------------------------------------------------------------------

+ (NSString *)punctuateMethodName:(NSString *)methodName
{
    return [@"-" stringByAppendingString:methodName];
}

@end
