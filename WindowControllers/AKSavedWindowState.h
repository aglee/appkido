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
{
@private
    AKWindowLayout *_savedWindowLayout;
    AKDocLocator *_savedDocLocator;
}

@property (nonatomic, strong) AKWindowLayout *savedWindowLayout;
@property (nonatomic, strong) AKDocLocator *savedDocLocator;

#pragma mark -
#pragma mark Getters and setters

- (AKWindowLayout *)savedWindowLayout;
- (void)setSavedWindowLayout:(AKWindowLayout *)windowLayout;

- (AKDocLocator *)savedDocLocator;
- (void)setSavedDocLocator:(AKDocLocator *)docLocator;

@end
