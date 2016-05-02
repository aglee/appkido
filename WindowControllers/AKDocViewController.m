//
//  AKDocViewController.m
//  AppKiDo
//
//  Created by Andy Lee on 2/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKDocViewController.h"
#import <WebKit/WebKit.h>
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKDatabase.h"
#import "AKDebugging.h"
#import "AKDoc.h"
#import "AKDocLocator.h"
#import "AKPrefUtils.h"
#import "AKWindowController.h"
#import "DocSetIndex.h"

@interface AKDocViewController ()
@property (nonatomic, strong) AKDocLocator *docLocator;
@end

@implementation AKDocViewController

@synthesize docLocator = _docLocator;
@synthesize tabView = _tabView;
@synthesize webView = _webView;
@synthesize textView = _textView;

#pragma mark - Init/dealloc/awake

- (instancetype)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
	self = [super initWithNibName:@"DocView" windowController:windowController];
	if (self) {
		_headerFontName = @"Monaco";
		_headerFontSize = 10;
		_docMagnifier = 100;
	}
	return self;
}

- (void)awakeFromNib
{
	WebPreferences *webPrefs = [WebPreferences standardPreferences];
	[webPrefs setAutosaves:NO];
	self.webView.preferences = webPrefs;

	// Turn off JavaScript, which interferes by hiding stuff we don't want to hide.
	self.webView.preferences.javaScriptEnabled = NO;

	[self applyUserPreferences];
}

#pragma mark - Navigation

- (NSView *)docView
{
	return ([self _isShowingWebView] ? _webView : _textView);
}

#pragma mark - AKViewController methods

- (void)goFromDocLocator:(AKDocLocator *)whereFrom toDocLocator:(AKDocLocator *)whereTo
{
	if ([whereTo isEqual:_docLocator]) {
		return;
	}
	self.docLocator = whereTo;
	[self _updateDocDisplay];
}

#pragma mark - AKUIController methods

- (void)applyUserPreferences
{
	if (_docLocator.docToDisplay.contentType == AKDocHTMLContentType) {
		NSInteger docMagnifierPref = [AKPrefUtils intValueForPref:AKDocMagnificationPrefName];
		if (_docMagnifier != docMagnifierPref) {
			_docMagnifier = docMagnifierPref;
			[self _updateDocDisplay];
		}
	} else {
		NSString *headerFontNamePref = [AKPrefUtils stringValueForPref:AKHeaderFontNamePrefName];
		NSInteger headerFontSizePref = [AKPrefUtils intValueForPref:AKHeaderFontSizePrefName];
		BOOL headerFontChanged = NO;

		if (![_headerFontName isEqualToString:headerFontNamePref]) {
			headerFontChanged = YES;

			// Standard setter pattern.
			_headerFontName = [headerFontNamePref copy];
		}

		if (_headerFontSize != headerFontSizePref) {
			headerFontChanged = YES;

			_headerFontSize = headerFontSizePref;
		}

		if (headerFontChanged) {
			[self _updateDocDisplay];
		}
	}
}

#pragma mark - WebPolicyDelegate methods

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id <WebPolicyDecisionListener>)listener
{
	NSNumber *navType = actionInformation[WebActionNavigationTypeKey];
	BOOL isLinkClicked = ((navType != nil)
						  && (navType.intValue == WebNavigationTypeLinkClicked));
	if (isLinkClicked) {
		NSEvent *currentEvent = NSApp.currentEvent;
		AKWindowController *wc = ((currentEvent.modifierFlags & NSCommandKeyMask)
								  ? [[AKAppDelegate appDelegate] controllerForNewWindow]
								  : self.owningWindowController);

		// Use a delayed perform to avoid mucking with the WebView's
		// display while it's in the middle of processing a UI event.
		// Note that the return value of -followLinkURL: will be lost.
		[wc performSelector:@selector(followLinkURL:) withObject:request.URL afterDelay:0];
	} else {
		[listener use];
	}
}

#pragma mark - WebUIDelegate methods

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSURL *linkURL = element[WebElementLinkURLKey];
	NSMutableArray *newMenuItems = [NSMutableArray array];

	// Don't have a contextual menu if there is nothing in the doc view.
	if ([self.owningWindowController currentDocLocator] == nil) {
		return newMenuItems;
	}

	// Cherry-pick from the contextual menu items that Cocoa proposes by default.
	NSMenuItem *speechMenuItem = nil;
	for (NSMenuItem *menuItem in defaultMenuItems) {
		NSInteger tag = menuItem.tag;

		if (tag == WebMenuItemTagOpenLinkInNewWindow) {
			// Change this menu item so instead of opening the link
			// in a new *web* browser window, it opens a new *AppKiDo*
			// browser window.
			menuItem.action = @selector(openLinkInNewWindow:);
			[menuItem setTarget:nil];  // will go to first responder
			menuItem.representedObject = linkURL;

			[newMenuItems addObject:menuItem];
		} else if ((tag == WebMenuItemTagDownloadImageToDisk)
				 || (tag == WebMenuItemTagCopyImageToClipboard)
				 || (tag == WebMenuItemTagSearchInSpotlight)
				 || (tag == WebMenuItemTagCopy)
				 || (tag == WebMenuItemTagSearchWeb)
				 || (tag == WebMenuItemTagLookUpInDictionary)) {

			[newMenuItems addObject:menuItem];
		}
		else if (tag == 2015) {  //TODO: The "Speech" item. There's no constant for this. Figured it out empirically.
			speechMenuItem = menuItem;
		}
	}

	// Separate system-provided menu items from application-specific ones.
	if (newMenuItems.count > 0) {
		[newMenuItems addObject:[NSMenuItem separatorItem]];
	}

	// Add menu items specific to AppKiDo.
	[self _addMenuItemWithTitle:@"Copy Page URL"
						 action:@selector(copyDocFileURL:)
						toArray:newMenuItems];
	[self _addMenuItemWithTitle:@"Copy File Path"
						 action:@selector(copyDocFilePath:)
						toArray:newMenuItems];
	[self _addMenuItemWithTitle:@"Open Page in Browser"
						 action:@selector(openDocFileInBrowser:)
						toArray:newMenuItems];
	[self _addMenuItemWithTitle:@"Reveal In Finder"
						 action:@selector(revealDocFileInFinder:)
						toArray:newMenuItems];
	if ([AKDebugging userCanDebug]) {
		[self _addMenuItemWithTitle:@"Open Parse Window (Debug)"
							 action:@selector(openParseDebugWindow:)
							toArray:newMenuItems];
	}

	// Manually add the "Speech" item *after* our custom items. Note: AppKit
	// will add the "Services" menu if appropriate. That menu is not one of the
	// proposed ones in defaultMenuItems.
	if (speechMenuItem) {
		[newMenuItems addObject:[NSMenuItem separatorItem]];
		[newMenuItems addObject:speechMenuItem];
	}

	return newMenuItems;
}

#pragma mark - Private methods

- (BOOL)_isShowingWebView
{
	NSView *viewSelectedInTabView = _tabView.selectedTabViewItem.view;
	return [_webView isDescendantOf:viewSelectedInTabView];
}

- (void)_updateDocDisplay
{
	if (_docLocator == nil) {
		[self _displayEmptyContent];
		return;
	}

	AKDoc *docToDisplay = _docLocator.docToDisplay;
	switch (docToDisplay.contentType) {
		case AKDocHTMLContentType: {
			DocSetIndex *docSetIndex = self.owningWindowController.database.docSetIndex;
			NSURL *docURL = [docToDisplay docURLWithBaseURL:docSetIndex.documentsBaseURL];
			QLog(@"+++ HTML doc URL: %@", docURL);
			[self _displayHTMLContentAtURL:docURL];
			break;
		}
		case AKDocObjectiveCContentType: {
			NSString *sdkPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk";  //TODO: Get the right path.
			NSURL *baseURL = [NSURL fileURLWithPath:sdkPath];
			NSURL *docURL = [docToDisplay docURLWithBaseURL:baseURL];
			QLog(@"+++ Objective-C doc URL: %@", docURL);
			[self _displayObjectiveCContentAtURL:docURL];
			break;
		}
		default: {
			QLog(@"+++ [ODD] Unexpected AKDoc content type %zd", docToDisplay.contentType);
			[self _displayEmptyContent];
		}
	}
}

- (void)_displayEmptyContent
{
	[self.tabView selectTabViewItemWithIdentifier:@"Empty"];
}

- (void)_displayHTMLContentAtURL:(NSURL *)docURL
{
	if (docURL == nil) {
		[self _displayEmptyContent];
		return;
	}

	[self.tabView selectTabViewItemWithIdentifier:@"WebView"];
	float multiplier = ((float)_docMagnifier) / 100.0f;
	self.webView.textSizeMultiplier = multiplier;

	NSURLRequest *req = [NSURLRequest requestWithURL:docURL];
	[self.webView.mainFrame loadRequest:req];
}

- (void)_displayObjectiveCContentAtURL:(NSURL *)docURL
{
	if (docURL == nil) {
		[self _displayEmptyContent];
		return;
	}

	NSError *error;
	NSString *objc = [[NSString alloc] initWithContentsOfURL:docURL encoding:NSUTF8StringEncoding error:&error];

	if (objc == nil) {
		QLog(@"+++ [ODD] Error loading doc URL %@", docURL);
		[self _displayEmptyContent];
		return;
	}

	NSString *html = [self _wrapHTMLAroundObjC:objc];
	[self.webView.mainFrame loadHTMLString:html baseURL:nil];
}

- (NSString *)_templateForWrappingHTMLAroundObjC
{
	static dispatch_once_t once;
	static NSString *s_template;
	dispatch_once(&once, ^{
		NSString *resourceName = @"objc";
		NSString *extension = @"html";
		NSURL *templateURL = [[NSBundle mainBundle] URLForResource:resourceName withExtension:extension];

		if (templateURL == nil) {
			QLog(@"+++ [ERROR] Couldn't find ", resourceName, extension);
		} else {
			NSError *error;
			s_template = [[NSString alloc] initWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:&error];
			if (s_template == nil) {
				QLog(@"+++ [ERROR] Couldn't load HTML template at URL %@ -- %@", templateURL, error);
			}
		}
	});

	return s_template;
}

- (NSString *)_wrapHTMLAroundObjC:(NSString *)objc
{
	NSString *html = [self _templateForWrappingHTMLAroundObjC];

	html = [html stringByReplacingOccurrencesOfString:@"%objc%" withString:objc];

	return html;
}

- (void)_useTextViewToDisplayPlainText:(NSData *)textData
{
	[_tabView selectTabViewItemWithIdentifier:@"TextView"];

	NSString *fontName = [AKPrefUtils stringValueForPref:AKHeaderFontNamePrefName];
	NSInteger fontSize = [AKPrefUtils intValueForPref:AKHeaderFontSizePrefName];
	NSFont *plainTextFont = [NSFont fontWithName:fontName size:fontSize];
	NSString *docString = @"";

	if (textData) {
		docString = [[NSString alloc] initWithData:textData
										  encoding:NSUTF8StringEncoding];
	}

	[_textView setRichText:NO];
	_textView.font = plainTextFont;

	_textView.string = docString;
	[_textView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)_useWebViewToDisplayHTML:(NSData *)htmlData fromFile:(NSString *)htmlFilePath
{
	[_tabView selectTabViewItemWithIdentifier:@"WebView"];

	// Apply the user's magnification preference.
	float multiplier = ((float)_docMagnifier) / 100.0f;

	_webView.textSizeMultiplier = multiplier;

	// Display the HTML in _webView.
	NSString *htmlString = @"";
	if (htmlData) {
		htmlString = [[NSString alloc] initWithData:htmlData
										   encoding:NSUTF8StringEncoding];
	}
	if (htmlFilePath) {
		[_webView.mainFrame loadHTMLString:htmlString
								   baseURL:[NSURL fileURLWithPath:htmlFilePath]];
	} else {
		[_webView.mainFrame loadHTMLString:htmlString baseURL:nil];
	}
}

// Used for setting up our contextual menu.
- (void)_addMenuItemWithTitle:(NSString *)menuItemTitle
					   action:(SEL)menuItemAction
					  toArray:(NSMutableArray *)menuItems
{
	// Leave the target nil so actions will go to first responder.
	NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:menuItemTitle
													  action:menuItemAction
											   keyEquivalent:@""];
	[menuItems addObject:menuItem];
}

@end
