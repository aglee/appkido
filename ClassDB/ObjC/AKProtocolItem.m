//
// AKProtocolItem.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKProtocolItem.h"

@implementation AKProtocolItem

- (BOOL)isInformal
{
	return (self.tokenMO.metainformation.declaredIn.headerPath == nil); //TODO: Is this a reliable test for informal protocols?  Some might be declared as categories (e.g. on NSObject), and thus have a headerPath.
}

@end
