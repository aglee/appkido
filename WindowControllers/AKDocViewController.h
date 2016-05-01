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
    NSTabView *__weak _tabView;  // Two tabs, one containing _webView and the other _textView.
    WebView *__weak _webView;
    NSTextView *__unsafe_unretained _textView;
}

@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet WebView *webView;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

#pragma mark - Navigation

/*! Returns either the web view or the text view. */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *docView;

@end
