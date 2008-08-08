//
//  AKDevToolsPathController.h
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AKDevToolsPathController : NSObject
{
    IBOutlet NSTextField *_devToolsPathField;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

/*! Returns an instance attached to a pre-existing UI via textField. */
+ (AKDevToolsPathController *)controllerWithTextField:(NSTextField *)textField;

+ (AKDevToolsPathController *)controllerWithNib;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*!  This is not the designated initializer -- -init is. */
- (id)initWithTextField:(NSTextField *)textField;

/*!  This is not the designated initializer -- -init is. */
- (id)initWithNib;

//-------------------------------------------------------------------------
// Running the panel
//-------------------------------------------------------------------------

/*!
 * Does a rough sanity check on a directory that is claimed to be a
 * Dev Tools directory.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath;

//-------------------------------------------------------------------------
// Action methods
//-------------------------------------------------------------------------

- (IBAction)runOpenPanel:(id)sender;

- (IBAction)ok:(id)sender;

- (IBAction)cancel:(id)sender;

@end
