//
//  AKDocSetsWindowController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/5/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDocSetsWindowController.h"
#import "AKInstalledSDK.h"
#import "DIGSLog.h"
#import "DocSetIndex.h"
#import "NSArray+AppKiDo.h"

@interface AKDocSetsWindowController ()
@property (strong) IBOutlet NSArrayController *docSetsArrayController;
@property (strong) NSMutableArray *docSetsWithInstalledSDKs;
@property (strong) NSMutableDictionary *sdksByPlatform;
@end

@implementation AKDocSetsWindowController

#pragma mark - Getters and setters

- (DocSetIndex *)selectedDocSetIndex
{
	return self.docSetsArrayController.selectedObjects.firstObject;
}

- (AKInstalledSDK *)selectedSDK
{
	DocSetIndex *docSetIndex = self.docSetsArrayController.selectedObjects.firstObject;
	if (docSetIndex == nil) {
		return nil;
	}
	return self.sdksByPlatform[docSetIndex.platform];
}

#pragma mark - Setup

- (void)useInstalledSDKsInXcodePath:(NSString *)xcodePath
{
	NSArray *installedSDKs = [AKInstalledSDK sdksWithinXcodePath:xcodePath];

	// The SDKs are sorted by platform and version, so this will give us a
	// dictionary with the highest version for each platform.
	self.sdksByPlatform = [NSMutableDictionary dictionary];
	for (AKInstalledSDK *sdk in installedSDKs) {
		self.sdksByPlatform[sdk.platform] = sdk;
	}

	self.docSetsWithInstalledSDKs = [NSMutableArray array];
	for (DocSetIndex *docSetIndex in [DocSetIndex installedDocSets]) {
		AKInstalledSDK *sdk = self.sdksByPlatform[docSetIndex.platform];
		if (sdk) {
			[self.docSetsWithInstalledSDKs addObject:docSetIndex];
		}
	}
}

#pragma mark - Action methods

- (IBAction)okDocSetsWindow:(id)sender
{
	[NSApp stopModal];
}

- (IBAction)cancelDocSetsWindow:(id)sender
{
	[NSApp abortModal];
}

#pragma mark - <NSTableViewDelegate> methods

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	static NSDictionary *s_platformDisplayNames;
	if (s_platformDisplayNames == nil) {
		s_platformDisplayNames = @{ @"macosx" : @"OS X",
									@"iphoneos" : @"iOS",
									@"watchos" : @"watchOS",
									@"appletvos" : @"tvOS" };
	}

	DocSetIndex *docSetIndex = self.docSetsArrayController.arrangedObjects[row];
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier
															owner:self];
	if ([tableColumn.identifier isEqualToString:@"Platform"]) {
		cellView.textField.stringValue = (s_platformDisplayNames[docSetIndex.platform]
										  ?: docSetIndex.platform);
	} else if ([tableColumn.identifier isEqualToString:@"DocSetVersion"]) {
		cellView.textField.stringValue = docSetIndex.platformVersion;
	} else if ([tableColumn.identifier isEqualToString:@"SDKVersion"]) {
		AKInstalledSDK *sdk = self.sdksByPlatform[docSetIndex.platform];
		cellView.textField.stringValue = sdk.version;
	} else {
		QLog(@"+++ [ODD] Unexpected table column identifier '%@'.", tableColumn.identifier);
		cellView.textField.stringValue = @"???";
	}

	return cellView;
}

@end
