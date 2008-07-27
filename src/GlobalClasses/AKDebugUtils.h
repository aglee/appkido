/*
 * AKDebugUtils.h
 *
 * Created by Andy Lee on Mon May 09 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "AKFileSection.h"

//-------------------------------------------------------------------------
// Category of AKFileSection debugging methods
//-------------------------------------------------------------------------

@interface AKFileSection (Debugging)

- (NSMutableString *)_treeAsString;

@end



//-------------------------------------------------------------------------
// 
//-------------------------------------------------------------------------

@interface AKFileSectionDebug : NSObject
{
    IBOutlet NSWindow *_windowForTestParse;
    IBOutlet NSTextView *_parseInfoTextView;
    IBOutlet NSTextField *_filePathField;
}

+ (void)_testParser;

@end
