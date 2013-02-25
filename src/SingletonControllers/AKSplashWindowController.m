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

#pragma mark -
#pragma mark AKDatabase delegate methods

- (void)database:(AKDatabase *)database willLoadTokensForFramework:(NSString *)frameworkName
{
    [_splashMessage2Field setStringValue:frameworkName];
    [_splashMessage2Field display];
}

#pragma mark -
#pragma mark NSWindowController methods

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Put up the splash window.
    [_splashVersionField setStringValue:[[AKAppVersion appVersion] displayString]];
    [[self window] center];
    [[self window] makeKeyAndOrderFront:nil];

    // Populate the database(s) by parsing files for each of the selected frameworks in the user's prefs.
    [_splashMessageField setStringValue:@"Parsing files for framework:"];
    [_splashMessageField display];
}

@end
