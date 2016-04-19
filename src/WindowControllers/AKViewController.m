/*
 * AKViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

@implementation AKViewController

@synthesize owningWindowController = _owningWindowController;

#pragma mark -
#pragma mark Init/dealloc/awake

- (instancetype)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
    self = [super initWithNibName:nibName bundle:nil];
    if (self)
    {
        _owningWindowController = windowController;
    }

    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithNibName:nil windowController:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithNibName:nil windowController:nil];
}

#pragma mark -
#pragma mark Getters and setters

- (AKWindowController *)owningWindowController
{
    return _owningWindowController;
}

#pragma mark -
#pragma mark Navigation

- (void)goFromDocLocator:(AKDocLocator *)whereFrom toDocLocator:(AKDocLocator *)whereTo
{
}

#pragma mark -
#pragma mark AKUIController methods

- (void)applyUserPreferences
{
}

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout
{
}

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout
{
}

#pragma mark -
#pragma mark NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
{
    return NO;
}

@end
