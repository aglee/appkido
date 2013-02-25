/*
 * AKWindowSubcontroller.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowSubcontroller.h"

@implementation AKWindowSubcontroller

- (AKWindowController *)owningWindowController
{
    return _windowController;
}

@end
