//
//  AKDocViewController.m
//  AppKiDo
//
//  Created by Andy Lee on 2/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKDocViewController.h"
#import "AKAppDelegate.h"
#import "AKDatabase.h"
#import "AKDebugging.h"
#import "AKDoc.h"
#import "AKDocLocator.h"
#import "AKNamedObject.h"
#import "AKPrefUtils.h"
#import "AKWindowController.h"
#import "DocSetIndex.h"
#import "DIGSLog.h"
#import <WebKit/WebKit.h>

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

- (NSURL *)docURL
{
	id<AKDoc> docToDisplay = _docLocator.docToDisplay;
	if (docToDisplay == nil) {
		return nil;
	}
	DocSetIndex *docSetIndex = self.owningWindowController.database.docSetIndex;
	return [docToDisplay docURLAccordingToDocSetIndex:docSetIndex];
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

#pragma mark - AKUIConfigurable methods

- (void)applyUserPreferences
{
	BOOL prefsDidChange = NO;
	NSInteger docMagnifierPref = [AKPrefUtils intValueForPref:AKDocMagnificationPrefName];
	NSString *headerFontNamePref = [AKPrefUtils stringValueForPref:AKHeaderFontNamePrefName];
	NSInteger headerFontSizePref = [AKPrefUtils intValueForPref:AKHeaderFontSizePrefName];

	if (_docMagnifier != docMagnifierPref) {
		_docMagnifier = docMagnifierPref;
		prefsDidChange = YES;
	}

	if (![_headerFontName isEqualToString:headerFontNamePref]) {
		prefsDidChange = YES;
		_headerFontName = [headerFontNamePref copy];
	}

	if (_headerFontSize != headerFontSizePref) {
		prefsDidChange = YES;

		_headerFontSize = headerFontSizePref;
	}

	if (prefsDidChange) {
		[self _updateDocDisplay];
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
	[self _addMenuItemWithTitle:@"Open Page in Browser"
						 action:@selector(openDocFileInBrowser:)
						toArray:newMenuItems];
	if ([[self docURL] isFileURL]) {
		[self _addMenuItemWithTitle:@"Copy File Path"
							 action:@selector(copyDocFilePath:)
							toArray:newMenuItems];
		[self _addMenuItemWithTitle:@"Reveal in Finder"
							 action:@selector(revealDocFileInFinder:)
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
	NSURL *docURL = [self docURL];
	QLog(@"+++ Doc URL: %@", docURL);

	if (docURL == nil) {
		[self _displayEmptyContent];
	} else if ([docURL.pathExtension isEqualToString:@"h"]) {
		[self _displayObjectiveCContentAtURL:docURL];
	} else {
		[self _displayHTMLContentAtURL:docURL];
	}
}

- (void)_displayEmptyContent
{
	[self.tabView selectTabViewItemWithIdentifier:@"Empty"];
}

- (void)_displayHTMLContentAtURL:(NSURL *)docURL
{
	[self.tabView selectTabViewItemWithIdentifier:@"WebView"];

	float multiplier = ((float)_docMagnifier) / 100.0f;
	self.webView.textSizeMultiplier = multiplier;

	NSURLRequest *req = [NSURLRequest requestWithURL:docURL];
	[self.webView.mainFrame loadRequest:req];
}

- (void)_displayObjectiveCContentAtURL:(NSURL *)docURL
{
	NSError *error;
	NSString *objc = [[NSString alloc] initWithContentsOfURL:docURL encoding:NSUTF8StringEncoding error:&error];

	if (objc == nil) {
		QLog(@"+++ [ODD] Error loading doc URL %@", docURL);
		[self _displayEmptyContent];
		return;
	}

	[self.tabView selectTabViewItemWithIdentifier:@"WebView"];

	NSString *html = [self _wrapHTMLAroundObjC:objc];
	[self.webView.mainFrame loadHTMLString:html baseURL:nil];
}

- (NSString *)_templateForWrappingHTMLAroundObjC
{
	static NSString *s_template;
	static dispatch_once_t once;
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
	objc = [objc stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];

	NSString *html = [self _templateForWrappingHTMLAroundObjC];

	html = [html stringByReplacingOccurrencesOfString:@"%objc%" withString:objc];

	return html;
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
