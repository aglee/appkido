/*
 * AKSavedWindowState.h
 *
 * Created by Andy Lee on Sun Jun 15 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AKPrefDictionary.h"

@class AKWindowLayout;
@class AKDocLocator;

/*!
 * Used to remember a browser window's display state between launches of the
 * app. Remembers two things: the window's physical layout, and what doc it was
 * displaying.
 */
@interface AKSavedWindowState : NSObject <AKPrefDictionary>

@property (strong) AKWindowLayout *savedWindowLayout;
@property (strong) AKDocLocator *savedDocLocator;

@end
