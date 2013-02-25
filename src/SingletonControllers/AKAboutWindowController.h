//
//  AKAboutWindowController.h
//  AppKiDo
//
//  Created by Andy Lee on 7/13/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface AKAboutWindowController : NSWindowController
{
@private
    IBOutlet WebView *_creditsView;
}

@end
