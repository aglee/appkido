//
//  AKDocSetsWindowController.h
//  AppKiDo
//
//  Created by Andy Lee on 6/5/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DocSetIndex;
@class AKInstalledSDK;

@interface AKDocSetsWindowController : NSWindowController <NSTableViewDelegate>

@property (readonly) DocSetIndex *selectedDocSetIndex;
@property (readonly) AKInstalledSDK *selectedSDK;

#pragma mark - Setup

/*! Need to call this to populate the docsets table view. */
- (void)useInstalledSDKsInXcodePath:(NSString *)xcodePath;

@end
