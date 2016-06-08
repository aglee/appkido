//
//  AKDevToolsPrefsViewController.h
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Presents a UI for the user to tell us where Xcode is.
 */
@interface AKDevToolsViewController : NSViewController <NSOpenSavePanelDelegate>

@property (copy) NSString *selectedXcodeAppPath;

@end
