//
//  AKDebugging.m
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKDebugging.h"
#import "AKAppDelegate.h"
#import "AKDatabaseOutlineExporter.h"
#import "AKDatabaseFlatFormatExporter.h"
#import "AKTabChain.h"
#import "AKWindow.h"
#import "AKWindowController.h"
#import "DIGSLog.h"
#import "NSObject+AppKiDo.h"

@implementation AKDebugging

#pragma mark - Factory methods

+ (AKDebugging *)sharedInstance
{
	static AKDebugging *s_sharedInstance;
	static dispatch_once_t once;
	dispatch_once(&once,^{
		s_sharedInstance = [[self alloc] init];
	});

	return s_sharedInstance;
}

#pragma mark - Initial setup

+ (BOOL)userCanDebug  //TODO: Make this a BOOL setting in NSUserDefaults.
{
	return ([NSUserName() isEqualToString:@"alee"]
			&& [NSFullUserName() isEqualToString:@"Andy Lee"]);
}

- (void)addDebugMenu
{
	// Add the "Debug" menu item to the menu bar.
	NSMenu *mainMenu = NSApp.mainMenu;
	NSMenuItem *debugMenuItem = [mainMenu addItemWithTitle:@"Debug"
													action:nil
											 keyEquivalent:@""];
	[debugMenuItem setEnabled:YES];

	// Create the submenu that will be under the "Debug" top-level menu item.
	NSMenu *debugSubmenu = [[NSMenu alloc] initWithTitle:@"Debug"];

	[debugSubmenu setAutoenablesItems:NO];

	[debugSubmenu addItemWithTitle:@"Print Database in Flat Format"
							action:@selector(printDatabaseInFlatFormat:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print Outline of Whole Database"
							action:@selector(printDatabaseAsOutline:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print Outline of Frameworks"
							action:@selector(printFrameworksAsOutline:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print Outline of Protocols"
							action:@selector(printProtocolsAsOutline:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print Outline of Classes"
							action:@selector(printClassesAsOutline:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print First Responder"
							action:@selector(printFirstResponder:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print Modified Tab Chain"
							action:@selector(printModifiedTabChain:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print Unmodified Tab Chain"
							action:@selector(printUnmodifiedTabChain:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print nextValidKeyView Loop"
							action:@selector(printValidKeyViewLoop:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print nextKeyView Loop"
							action:@selector(printEntireKeyViewLoop:)
					 keyEquivalent:@""];
	[debugSubmenu addItemWithTitle:@"Print Window Info"
							action:@selector(printFunWindowFacts:)
					 keyEquivalent:@""];

	// Attach the submenu to the "Debug" top-level menu item.
	[mainMenu setSubmenu:debugSubmenu forItem:debugMenuItem];
}

#pragma mark - Action methods

- (IBAction)printDatabaseInFlatFormat:(id)sender
{
	AKDatabaseFlatFormatExporter *exporter = [[AKDatabaseFlatFormatExporter alloc] init];
	AKDatabase *database = AKAppDelegate.appDelegate.appDatabase;
	[exporter printContentsOfDatabase:database];
}

- (IBAction)printDatabaseAsOutline:(id)sender
{
	AKDatabaseOutlineExporter *exporter = [[AKDatabaseOutlineExporter alloc] init];
	AKDatabase *database = AKAppDelegate.appDelegate.appDatabase;
	[exporter printFullOutlineOfDatabase:database];
}

- (IBAction)printFrameworksAsOutline:(id)sender
{
	AKDatabaseOutlineExporter *exporter = [[AKDatabaseOutlineExporter alloc] init];
	AKDatabase *database = AKAppDelegate.appDelegate.appDatabase;
	[exporter printOutlineOfFrameworksInDatabase:database];
}

- (IBAction)printProtocolsAsOutline:(id)sender
{
	AKDatabaseOutlineExporter *exporter = [[AKDatabaseOutlineExporter alloc] init];
	AKDatabase *database = AKAppDelegate.appDelegate.appDatabase;
	[exporter printOutlineOfProtocolsInDatabase:database];
}

- (IBAction)printClassesAsOutline:(id)sender
{
	AKDatabaseOutlineExporter *exporter = [[AKDatabaseOutlineExporter alloc] init];
	AKDatabase *database = AKAppDelegate.appDelegate.appDatabase;
	[exporter printOutlineOfProtocolsInDatabase:database];
}

- (IBAction)printFirstResponder:(id)sender
{
	id firstResponder = NSApp.keyWindow.firstResponder;
	if (firstResponder == nil) {
		NSLog(@"The key window has no first responder.");
	} else {
		NSLog(@"The key window's first responder is <%@: %p>.", [firstResponder className], firstResponder);
	}
}

- (IBAction)printModifiedTabChain:(id)sender
{
	NSLog(@"MODIFIED TAB CHAIN for %@", [NSApp.keyWindow ak_bareDescription]);
	for (NSView *v in [AKTabChain modifiedTabChainForWindow:NSApp.keyWindow]) {
		NSLog(@"  %@", [v ak_bareDescription]);
	}
	NSLog(@"END MODIFIED TAB CHAIN for %@\n\n", [NSApp.keyWindow ak_bareDescription]);
}

- (IBAction)printUnmodifiedTabChain:(id)sender
{
	NSLog(@"UNMODIFIED TAB CHAIN for %@", [NSApp.keyWindow ak_bareDescription]);
	for (NSView *v in [AKTabChain unmodifiedTabChainForWindow:NSApp.keyWindow]) {
		NSLog(@"  %@", [v ak_bareDescription]);
	}
	NSLog(@"END UNMODIFIED TAB CHAIN for %@\n\n", [NSApp.keyWindow ak_bareDescription]);
}

- (IBAction)printValidKeyViewLoop:(id)sender
{
	[self _printViewSequenceWithKeyPath:@"nextValidKeyView"];
}

- (IBAction)printEntireKeyViewLoop:(id)sender
{
	[self _printViewSequenceWithKeyPath:@"nextKeyView"];
}

- (IBAction)printFunWindowFacts:(id)sender
{
	AKWindowController *wc = [[AKAppDelegate appDelegate] frontmostWindowController];
	if (wc == nil) {
		NSLog(@"No AppKiDo window is open.");
	} else {
		[wc printFunFacts:sender];
	}
}

#pragma mark - Private methods

- (void)_printViewSequenceWithKeyPath:(NSString *)nextViewKeyPath
{
	[self printFirstResponder:nil];
	id firstResponder = NSApp.keyWindow.firstResponder;
	if ([firstResponder isKindOfClass:[NSView class]]) {
		[firstResponder ak_printSequenceWithValuesForKeyPaths:nil
											nextObjectKeyPath:nextViewKeyPath];
	}
}

@end
