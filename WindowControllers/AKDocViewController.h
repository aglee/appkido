//
//  AKDocViewController.h
//  AppKiDo
//
//  Created by Andy Lee on 2/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKViewController.h"
#import <WebKit/WebKit.h>

@class WebView;

@interface AKDocViewController : AKViewController <WebPolicyDelegate, WebUIDelegate>
{
@private
	AKDocLocator *_docLocator;

	NSString *_headerFontName;
	NSInteger _headerFontSize;
	NSInteger _docMagnifier;

	// IBOutlets.
	NSTabView *__weak _tabView;
	WebView *__weak _webView;
	NSTextView *__unsafe_unretained _textView;
}

@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet WebView *webView;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

#pragma mark - Navigation

/*! Returns either the web view or the text view. */
@property (readonly, strong) NSView *docView;

- (NSURL *)docURL;

@end
