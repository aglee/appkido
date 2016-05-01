//
//  AKSplashWindowController.m
//  AppKiDo
//
//  Created by Andy Lee on 2/16/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKSplashWindowController.h"

#import "AKAppVersion.h"

@implementation AKSplashWindowController

@synthesize splashVersionField = _splashVersionField;
@synthesize splashMessageField = _splashMessageField;
@synthesize splashMessage2Field = _splashMessage2Field;

#pragma mark - NSWindowController methods

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Put up the splash window.
    _splashVersionField.stringValue = [[AKAppVersion appVersion] displayString];
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    _splashMessageField.stringValue = @"Parsing files for framework:";
    [_splashMessageField display];
}

@end
