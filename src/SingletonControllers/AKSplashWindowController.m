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

- (void)dealloc
{
    [_splashVersionField release];
    [_splashMessageField release];
    [_splashMessage2Field release];

    [super dealloc];
}

#pragma mark - AKDatabase delegate methods

- (void)database:(AKDatabase *)database willLoadTokensForFramework:(NSString *)frameworkName
{
    [_splashMessage2Field setStringValue:frameworkName];
    [_splashMessage2Field display];
}

#pragma mark - NSWindowDelegate methods

// <http://stackoverflow.com/questions/1391260/who-owns-an-nswindowcontroller-in-standard-practice>
// <http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/WinPanel/Concepts/UsingWindowController.html>
// <blockquote>
// When a window is closed and it is part of a document-based application, the document removes the window’s window controller from its list of window controllers. This results in the system deallocating the window controller and the window, and possibly the NSDocument object itself. When a window controller is not part of a document-based application, closing the window does not by default result in the deallocation of the window or window controller. This is the desired behavior for a window controller that manages something like an inspector; you shouldn’t have to load the nib file again and re-create the objects the next time the user requests the inspector.
//
// If you want the closing of a window to make both window and window controller go away when it isn’t part of a document, your subclass of NSWindowController can observe the NSWindowWillCloseNotification notification or, as the window delegate, implement the windowWillClose: method.
// </blockquote>
- (void) windowWillClose:(NSNotification *)notification
{
    [self autorelease];
}

#pragma mark - NSWindowController methods

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
