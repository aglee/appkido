/*
 * DIGSWindow.h
 *
 * Created by Andy Lee on Wed Apr 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * @class       DIGSWindow
 * @abstract    Small tweak to NSWindow.
 * @discussion  Originally this was a placeholder class that you could pose as
 *              if you wanted to modify the behavior of NSWindows but not
 *              NSPanels.  I don't need this ability any more, because I'm
 *              getting rid of metal windows.  All DIGSWindow contains now is
 *              an override of -setTitle: that protects against nil being passed
 *              as the title.
 */
@interface DIGSWindow : NSWindow
{
}

@end
