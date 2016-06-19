//
//  AKDocSetsWindowController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/5/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDocSetsWindowController.h"
#import "AKInstalledSDK.h"
#import "AKPrefUtils.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"
#import "NSArray+AppKiDo.h"

@interface AKDocSetsWindowController ()
@property (strong) IBOutlet NSArrayController *docSetsArrayController;
@end

@implementation AKDocSetsWindowController

@synthesize selectedXcodePath = _selectedXcodePath;

#pragma mark - Getters and setters

- (DocSetIndex *)selectedDocSetIndex
{
	NSDictionary *tableRowObject = self.docSetsArrayController.selectedObjects.firstObject;
	return tableRowObject[@"docSetIndex"];
}

- (AKInstalledSDK *)selectedSDK
{
	NSDictionary *tableRowObject = self.docSetsArrayController.selectedObjects.firstObject;
	return tableRowObject[@"installedSDK"];
}

- (NSString *)selectedXcodePath
{
	return _selectedXcodePath;
}

// As a side effect, updates self.docSetsArrayController.content.
- (void)setSelectedXcodePath:(NSString *)selectedXcodePath
{
	_selectedXcodePath = selectedXcodePath;

	// For each platform, find the installed SDK with the highest version.
	NSArray *sortedSDKs = [AKInstalledSDK sortedSDKsWithinXcodePath:self.selectedXcodePath];
	NSMutableDictionary *sdksByPlatform = [NSMutableDictionary dictionary];
	for (AKInstalledSDK *sdk in sortedSDKs) {
		sdksByPlatform[sdk.platformInternalName] = sdk;
	}

	// Update docSetsArrayController.  Each row object is an NSDictionary whose
	// values are a DocSetIndex and an AKInstalledSDK for the same platform.
	NSMutableArray *tableRowObjects = [NSMutableArray array];
	for (DocSetIndex *docSetIndex in [DocSetIndex sortedDocSetsInStandardLocation]) {
		AKInstalledSDK *sdk = sdksByPlatform[docSetIndex.platformInternalName];
		if (sdk) {
			[tableRowObjects addObject:@{ @"docSetIndex" : docSetIndex,
										  @"installedSDK" : sdk }];
		}
	}
	self.docSetsArrayController.content = tableRowObjects;
}

#pragma mark - Action methods

// Displays an open panel sheet in self.window.
- (IBAction)selectXcode:(id)sender
{
	[self _promptForXcodeLocation];
}

- (IBAction)okDocSetsWindow:(id)sender
{
	[NSApp stopModal];
}

- (IBAction)cancelDocSetsWindow:(id)sender
{
	[NSApp abortModal];
}

#pragma mark - NSWindowController methods

- (void)windowDidLoad
{
	self.selectedXcodePath = [AKPrefUtils xcodePathPref];
}

#pragma mark - <NSOpenSavePanelDelegate> methods

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
	NSString *path = url.path;
	BOOL isDir = NO;

	// The path must be a directory.
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
		return NO;
	}
	if (!isDir) {
		return NO;
	}

	// If it's a .app directory, check that it's a supported version of Xcode.
	if ([path.pathExtension isEqualToString:@"app"]) {
		return [self _isSupportedXcodeAppAtPath:path];
	}

	// Any other directory is okay.
	return YES;
}

#pragma mark - Private methods

// Displays an open panel sheet in self.window.
- (void)_promptForXcodeLocation
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

	if (self.selectedXcodePath) {
		openPanel.directoryURL = [NSURL fileURLWithPath:self.selectedXcodePath];
	} else {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSURL *appDirURL = [fm URLsForDirectory:NSApplicationDirectory
									  inDomains:NSSystemDomainMask].lastObject;
		if (appDirURL) {
			openPanel.directoryURL = appDirURL;
		}
	}

	[openPanel beginSheetModalForWindow:self.window
					  completionHandler:^(NSInteger result) {
						  if (result == NSFileHandlingPanelOKButton) {
							  [openPanel orderOut:nil];
							  self.selectedXcodePath = openPanel.URL.path;
						  }
					  }];
}

// Assumes xcodePath points to a .app bundle.
- (BOOL)_isSupportedXcodeAppAtPath:(NSString *)appPath
{
	// Load the app's Info.plist.
	NSString *infoPlistPath = [appPath stringByAppendingPathComponent:@"Contents/Info.plist"];
	NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
	if (infoPlist == nil) {
		return NO;
	}

	// The bundle ID must indicate that the app is Xcode.
	NSString *bundleID = infoPlist[@"CFBundleIdentifier"];
	if (![bundleID isEqualToString:@"com.apple.dt.Xcode"]) {
		return NO;
	}

	// We only support docsets that use the Core Data docset index, which means
	// Xcode 6.x or 7.x.
	NSString *version = infoPlist[@"CFBundleShortVersionString"];
	if ([version compare:@"6"] == NSOrderedAscending) {
		return NO;
	}
	if ([version compare:@"8"] != NSOrderedAscending) {
		return NO;
	}

	// If we got this far, assume we have a valid and supported Xcode app bundle.
	return YES;
}

@end
