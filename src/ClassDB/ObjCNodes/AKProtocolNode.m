//
// AKProtocolNode.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKProtocolNode.h"

@implementation AKProtocolNode

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (BOOL)isInformal
{
    // ([agl] Is this a reliable test for informal protocols?)
    return ([self headerFileWhereDeclared] == nil);
}

@end
