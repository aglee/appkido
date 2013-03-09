//
//  AKDocViewController.h
//  AppKiDo
//
//  Created by Andy Lee on 2/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKViewController.h"

@class WebView;

@interface AKDocViewController : AKViewController
{
@private
    AKDocLocator *_docLocator;

    NSString *_headerFontName;
    NSInteger _headerFontSize;
    NSInteger _docMagnifier;

    // IBOutlets.
    NSTabView *_tabView;  // Two tabs, one containing _webView and the other _textView.
    WebView *_webView;
    NSTextView *_textView;
}

@property (nonatomic, assign) IBOutlet NSTabView *tabView;
@property (nonatomic, assign) IBOutlet WebView *webView;
@property (nonatomic, assign) IBOutlet NSTextView *textView;

#pragma mark -
#pragma mark Navigation

- (NSView *)docView;

@end
