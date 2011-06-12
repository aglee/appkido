/*
 * AKTextView.h
 *
 * Created by Andy Lee on Thu Mar 18 2007.
 * Copyright (c) 2003-2007 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "DIGSTextView.h"

/*!
 * Used by AKDocView to display header files.  Overrides insertTab: and
 * insertBacktab: to navigate to next and previous key views.
 */
@interface AKTextView : DIGSTextView
{
}

@end
