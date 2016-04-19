//
// AKProtocolNode.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKProtocolNode.h"

@implementation AKProtocolNode

- (BOOL)isInformal
{
    return (self.headerFileWhereDeclared == nil); //TODO: Is this a reliable test for informal protocols?  Some might be declared, just as categories, say, on NSObject.
}

@end
