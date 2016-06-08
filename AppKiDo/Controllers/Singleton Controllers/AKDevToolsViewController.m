//
//  AKDevToolsPrefsViewController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDevToolsViewController.h"
#import "AKPrefUtils.h"
#import "DIGSLog.h"

@implementation AKDevToolsViewController

@synthesize selectedXcodeAppPath = _selectedXcodeAppPath;

#pragma mark - Init/awake/dealloc

- (void)awakeFromNib
{
	// Grab the Xcode path from NSUserDefaults.
	self.selectedXcodeAppPath = [AKPrefUtils xcodePathPref];
}

#pragma mark - Getters and setters

- (NSString *)selectedXcodeAppPath
{
	return _selectedXcodeAppPath;
}

- (void)setSelectedXcodeAppPath:(NSString *)selectedXcodeAppPath
{
	_selectedXcodeAppPath = selectedXcodeAppPath;
	[AKPrefUtils setXcodePathPref:selectedXcodeAppPath];
}

#pragma mark - Action methods

// Displays an open panel sheet in self.view.window.
- (IBAction)promptForXcodeLocation:(id)sender
{
	// Even though a .app bundle is a directory and not a file, we pretend
	// otherwise when setting up the open panel.
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.delegate = self;
	openPanel.title = @"Locate Xcode.app";
	openPanel.prompt = @"Select Xcode";
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = NO;
	openPanel.canChooseFiles = YES;
	openPanel.resolvesAliases = YES;
	openPanel.allowedFileTypes = @[@"app"];

	if (_selectedXcodeAppPath) {
		openPanel.directoryURL = [NSURL fileURLWithPath:_selectedXcodeAppPath];
	} else {
		NSURL *appDirURL = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory
																  inDomains:NSSystemDomainMask].lastObject;
		if (appDirURL) {
			openPanel.directoryURL = appDirURL;
		}
	}

	[openPanel beginSheetModalForWindow:self.view.window
					  completionHandler:^(NSInteger result) {
						  if (result == NSFileHandlingPanelOKButton) {
							  self.selectedXcodeAppPath = openPanel.URL.path;
						  }
					  }];
}

#pragma mark - <NSOpenSavePanelDelegate> methods

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
	NSString *path = url.path;
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir = NO;

	// The path must be a .app directory.
	if (![fm fileExistsAtPath:path isDirectory:&isDir]) {
		return NO;
	}
	if (!isDir) {
		return NO;
	}
	if (![path.pathExtension isEqualToString:@"app"]) {
		return NO;
	}

	// Sanity check to confirm that we're looking at an Xcode app bundle.
	return [fm fileExistsAtPath:[path stringByAppendingPathComponent:@"Contents/MacOS/Xcode"]];
}

@end
