/*
 * AKSavedWindowState.h
 *
 * Created by Andy Lee on Sun Jun 15 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKWindowLayout;
@class AKDocLocator;

/*!
 * @class       AKSavedWindowState
 * @abstract    Used to remember a browser window's display state between
 *              launches of the app.
 * @discussion  Remembers two things: the window's visual layout info, and
 *              what doc it was displaying.
 */
@interface AKSavedWindowState : NSObject
{
@private
    AKWindowLayout *_savedWindowLayout;
    AKDocLocator *_savedDocLocator;
}

#pragma mark -
#pragma mark Preferences

+ (AKSavedWindowState *)fromPrefDictionary:(NSDictionary *)prefDict;

- (NSDictionary *)asPrefDictionary;

#pragma mark -
#pragma mark Getters and setters

- (AKWindowLayout *)savedWindowLayout;
- (void)setSavedWindowLayout:(AKWindowLayout *)windowLayout;

- (AKDocLocator *)savedDocLocator;
- (void)setSavedDocLocator:(AKDocLocator *)docLocator;

@end
