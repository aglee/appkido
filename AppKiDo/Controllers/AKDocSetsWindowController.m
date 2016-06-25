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
	[self _repopulateDocsSetsArrayController];
}

- (void)_repopulateDocsSetsArrayController
{
	// For each platform, find the installed SDK with the highest version.
	NSArray *sortedSDKs = [AKInstalledSDK sortedSDKsWithinXcodePath:self.selectedXcodePath];
	NSMutableDictionary *sdksByPlatform = [NSMutableDictionary dictionary];
	for (AKInstalledSDK *sdk in sortedSDKs) {
		sdksByPlatform[sdk.platformInternalName] = sdk;
	}

	// Update docSetsArrayController.  Each row object is an NSDictionary whose
	// values are a DocSetIndex and/or an AKInstalledSDK for the same platform.
	// Each SDK is paired with the "nearest matching" docset.
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
//
// It would be helpful for the open panel to pre-select the user's current prefs
// value for the Xcode path, but it can't be done.  NSOpenPanel no longer has
// methods for pre-selecting a file before it is displayed.  We can only
// pre-select a directory, by setting the directoryURL property.  I can't even
// cheat by calling the deprecated methods -- they don't work.
//
// Since Xcode.app is a bundle, it's true that technically we do want to
// pre-select a directory.  But we want the open panel's file browser to *treat*
// it as a file, and not allow navigation to subdirectories.
//
// There is a bug in NSOpenPanel such that if I set directoryURL to
// /Applications/Xcode.app, it will actually pre-select Xcode.app, in violation
// of its own treatsFilePackagesAsDirectories property, which I set to NO, and
// which defaults to NO anyway.  I would be tempted to exploit this bug, but
// unfortunately the file browser treats the package exactly like a directory
// and exposes the app bundle's "Contents" subdirectory.
//
//TODO: File a Radar about NSOpenPanel and add links here, e.g. to my question on cocoa-dev.
- (IBAction)selectXcode:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.delegate = self;
	openPanel.title = @"Locate Xcode.app";
	openPanel.prompt = @"Select Xcode";
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = NO;
	openPanel.canChooseFiles = YES;
	openPanel.resolvesAliases = YES;
	openPanel.allowedFileTypes = @[@"app"];
	openPanel.treatsFilePackagesAsDirectories = NO;

	if (self.selectedXcodePath) {
		openPanel.directoryURL = [NSURL fileURLWithPath:self.selectedXcodePath.stringByDeletingLastPathComponent];
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

- (BOOL)_isSupportedXcodeAppAtPath:(NSString *)appPath
{
	// Must be a .app directory.
	if (![appPath.pathExtension isEqualToString:@"app"]) {
		return NO;
	}

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

	// We only support Xcode versions 6.x or 7.x, which use a Core Data-based
	// "docset index".  It doesn't work to check for the presence of the .dsidx
	// file, because that file is present in Xcode 8 (at least in beta 1).  So
	// we check the Xcode version string instead.
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
