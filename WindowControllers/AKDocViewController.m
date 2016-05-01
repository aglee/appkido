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
    if (self)
    {
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
    _webView.preferences = webPrefs;

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
    if ([whereTo isEqual:_docLocator])
    {
        return;
    }

    self.docLocator = whereTo;
    [self _updateDocDisplay];
}

#pragma mark - AKUIController methods

- (void)applyUserPreferences
{
    if ([[_docLocator docToDisplay] docTextIsHTML])
    {
        NSInteger docMagnifierPref = [AKPrefUtils intValueForPref:AKDocMagnificationPrefName];

        if (_docMagnifier != docMagnifierPref)
        {
            _docMagnifier = docMagnifierPref;
            [self _updateDocDisplay];
        }
    }
    else
    {
        NSString *headerFontNamePref = [AKPrefUtils stringValueForPref:AKHeaderFontNamePrefName];
        NSInteger headerFontSizePref = [AKPrefUtils intValueForPref:AKHeaderFontSizePrefName];
        BOOL headerFontChanged = NO;

        if (![_headerFontName isEqualToString:headerFontNamePref])
        {
            headerFontChanged = YES;

            // Standard setter pattern.
            _headerFontName = [headerFontNamePref copy];
        }

        if (_headerFontSize != headerFontSizePref)
        {
            headerFontChanged = YES;

            _headerFontSize = headerFontSizePref;
        }

        if (headerFontChanged)
        {
            [self _updateDocDisplay];
        }
    }
}

#pragma mark - WebPolicyDelegate methods

- (void)webView:(WebView *)sender
decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
          frame:(WebFrame *)frame
decisionListener:(id <WebPolicyDecisionListener>)listener
{
    NSNumber *navType = actionInformation[WebActionNavigationTypeKey];
    BOOL isLinkClicked = ((navType != nil)
                          && (navType.intValue == WebNavigationTypeLinkClicked));

    if (isLinkClicked)
    {
        NSEvent *currentEvent = NSApp.currentEvent;
        AKWindowController *wc = ((currentEvent.modifierFlags & NSCommandKeyMask)
                                  ? [[AKAppDelegate appDelegate] controllerForNewWindow]
                                  : self.owningWindowController);

        // Use a delayed perform to avoid mucking with the WebView's
        // display while it's in the middle of processing a UI event.
        // Note that the return value of -followLinkURL: will be lost.
        [wc performSelector:@selector(followLinkURL:) withObject:request.URL afterDelay:0];
    }
    else
    {
        [listener use];
    }
}

#pragma mark - WebUIDelegate methods

- (NSArray *)webView:(WebView *)sender
contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSURL *linkURL = element[WebElementLinkURLKey];
    NSMutableArray *newMenuItems = [NSMutableArray array];

    // Don't have a contextual menu if there is nothing in the doc view.
    if ([self.owningWindowController currentDocLocator] == nil)
    {
        return newMenuItems;
    }

    // Cherry-pick from the contextual menu items that Cocoa proposes by default.
    NSMenuItem *speechMenuItem = nil;
    for (NSMenuItem *menuItem in defaultMenuItems)
    {
        NSInteger tag = menuItem.tag;

        if (tag == WebMenuItemTagOpenLinkInNewWindow)
        {
            // Change this menu item so instead of opening the link
            // in a new *web* browser window, it opens a new *AppKiDo*
            // browser window.
            menuItem.action = @selector(openLinkInNewWindow:);
            [menuItem setTarget:nil];  // will go to first responder
            menuItem.representedObject = linkURL;

            [newMenuItems addObject:menuItem];
        }
        else if ((tag == WebMenuItemTagDownloadImageToDisk)
                 || (tag == WebMenuItemTagCopyImageToClipboard)
                 || (tag == WebMenuItemTagSearchInSpotlight)
                 || (tag == WebMenuItemTagCopy)
                 || (tag == WebMenuItemTagSearchWeb)
                 || (tag == WebMenuItemTagLookUpInDictionary))
        {
            [newMenuItems addObject:menuItem];
        }
        else if (tag == 2015)  //TODO: The "Speech" item. There's no constant for this. Figured it out empirically.
        {
            speechMenuItem = menuItem;
        }
    }

    // Separate system-provided menu items from application-specific ones.
    if (newMenuItems.count > 0)
    {
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
    if ([AKDebugging userCanDebug])
    {
        [self _addMenuItemWithTitle:@"Open Parse Window (Debug)"
                             action:@selector(openParseDebugWindow:)
                            toArray:newMenuItems];
    }

    // Manually add the "Speech" item *after* our custom items. Note: AppKit
    // will add the "Services" menu if appropriate. That menu is not one of the
    // proposed ones in defaultMenuItems.
    if (speechMenuItem)
    {
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
    if (_docLocator == nil)
    {
        return;
    }

    //  Figure out what text to display.
    AKDoc *docToDisplay = [_docLocator docToDisplay];

    if (docToDisplay.docTextIsHTML) {
        AKDatabase *db = self.owningWindowController.database;
        DocSetIndex *docSetIndex = db.docSetIndex;
        NSString *documentsPath = [docSetIndex.docSetPath stringByAppendingPathComponent:@"Contents/Resources/Documents"];
        //TODO: Handle fallback http URL.
        NSURL *docURL = [docToDisplay docURLWithBasePath:documentsPath];
        QLog(@"+++ docURL: %@", docURL);

        [self.tabView selectTabViewItemWithIdentifier:@"1"];
        float multiplier = ((float)_docMagnifier) / 100.0f;
        self.webView.textSizeMultiplier = multiplier;

        NSURLRequest *req = [NSURLRequest requestWithURL:docURL];
        [self.webView.mainFrame loadRequest:req];
    }





    
//TODO: Commenting out, come back later.
//    AKFileSection *fileSection = [docToDisplay fileSection];
//    NSString *htmlFilePath = [fileSection filePath];
//    NSData *textData = [docToDisplay docTextData];
//
//    // Display the text in either _textView or _webView.  Whichever it
//    // is, swap it in as our subview if necessary.
//    if ([docToDisplay docTextIsHTML])
//    {
//        [self _useWebViewToDisplayHTML:textData fromFile:htmlFilePath];
//    }
//    else
//    {
//        [self _useTextViewToDisplayPlainText:textData];
//
//        // Make extra sure the cursor rects are updated so we get the
//        // hand cursor over links.  Note: you'd think we should
//        // invalidate the cursor rects for textView, but no, for some
//        // reason it doesn't work unless we do it for scrollView.
//        [self.view.window invalidateCursorRectsForView:_textView.enclosingScrollView];
//    }
}

- (void)_useTextViewToDisplayPlainText:(NSData *)textData
{
//    // Make _scrollView our subview if it isn't already.
//    if (currentSubview != _scrollView)  // implies currentSubview is _webView
//    {
//        // Remove _webView from the key view loop.
//        id firstResponder = [[self window] firstResponder];
//        BOOL wasKey = ([firstResponder isKindOfClass:[NSView class]]
//                       && [firstResponder isDescendantOf:_webView]);
//        [_originalPreviousKeyView setNextKeyView:_originalNextKeyView];
//
//        // Swap in _scrollView as our subview.
//        [_scrollView setFrame:[currentSubview frame]];
//        [self replaceSubview:currentSubview with:_scrollView];
//
//        // Splice textView into the key view loop.
//        [_originalPreviousKeyView setNextKeyView:textView];
//        [textView setNextKeyView:_originalNextKeyView];
//        if (wasKey)
//        {
//            [[self window] makeFirstResponder:textView];
//        }
//    }

    [_tabView selectTabViewItemWithIdentifier:@"2"];

    NSString *fontName = [AKPrefUtils stringValueForPref:AKHeaderFontNamePrefName];
    NSInteger fontSize = [AKPrefUtils intValueForPref:AKHeaderFontSizePrefName];
    NSFont *plainTextFont = [NSFont fontWithName:fontName size:fontSize];
    NSString *docString = @"";
    
    if (textData)
    {
        docString = [[NSString alloc] initWithData:textData
                                           encoding:NSUTF8StringEncoding];
    }

    [_textView setRichText:NO];
    _textView.font = plainTextFont;

// Workaround for appkit bug (?) causing the last-used indentation
// level to stick to the text view even if I clear its contents and
// remove all its attributes.
//TODO: But now it causes assert error?
//    [[_textView layoutManager] replaceTextStorage:[[NSTextStorage alloc] initWithString:@""]];

    _textView.string = docString;
    [_textView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)_useWebViewToDisplayHTML:(NSData *)htmlData fromFile:(NSString *)htmlFilePath
{
//    // Make _webView our subview if it isn't already.
//    NSView *currentSubview = [self _subview];
//    NSTextView *textView = [_scrollView documentView];
//
//    if (currentSubview != _webView)  // implies currentSubview is _scrollView
//    {
//        // Remove textView from the key view loop.
//        BOOL wasKey = ([[self window] firstResponder] == textView);
//        [_originalPreviousKeyView setNextKeyView:_originalNextKeyView];
//
//        // Swap in _webView as our subview.
//        [_webView setFrame:[currentSubview frame]];
//        [self replaceSubview:currentSubview with:_webView];
//
//        // Splice _webView into the key view loop.
//        //TODO: -- the wasKey stuff doesn't work
//        [_originalPreviousKeyView setNextKeyView:_webView];
//        [_webView setNextKeyView:_originalNextKeyView];
//        if (wasKey)
//        {
//            [[self window] makeFirstResponder:_webView];
//        }
//    }

    [_tabView selectTabViewItemWithIdentifier:@"1"];

    // Apply the user's magnification preference.
    float multiplier = ((float)_docMagnifier) / 100.0f;

    _webView.textSizeMultiplier = multiplier;

    // Display the HTML in _webView.
    NSString *htmlString = @"";
    if (htmlData)
    {
        htmlString = [[NSString alloc] initWithData:htmlData
                                            encoding:NSUTF8StringEncoding];
    }

    if (htmlFilePath)
    {
        [_webView.mainFrame loadHTMLString:htmlString
                                     baseURL:[NSURL fileURLWithPath:htmlFilePath]];
    }
    else
    {
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
