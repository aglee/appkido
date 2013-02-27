//
//  AKDocViewController.m
//  AppKiDo
//
//  Created by Andy Lee on 2/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKDocViewController.h"

#import <WebKit/WebKit.h>

#import "AKDoc.h"
#import "AKDocLocator.h"
#import "AKFileSection.h"
#import "AKPrefUtils.h"
#import "AKTextUtils.h"
#import "AKTextView.h"

@interface AKDocViewController ()
@property (nonatomic, retain) AKDocLocator *docLocator;
@end

@implementation AKDocViewController

@synthesize docLocator = _docLocator;

@synthesize tabView = _tabView;
@synthesize webView = _webView;
@synthesize textView = _textView;

#pragma mark -
#pragma mark Init/dealloc/awake

- (id)initWithNibName:nibName windowController:(AKWindowController *)windowController
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

- (void)dealloc
{
    [_docLocator release];
    [_headerFontName release];

    [super dealloc];
}

- (void)awakeFromNib
{
    [self applyPrefs];
}

#pragma mark -
#pragma mark Getters and setters

#pragma mark -
#pragma mark UI behavior

- (void)applyPrefs
{
    if (![[_docLocator docToDisplay] isPlainText])
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
            [_headerFontName autorelease];
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

- (NSView *)grabFocus
{
    NSView *currentSubview = [[_tabView selectedTabViewItem] view];

    if (currentSubview == _webView)
    {
        return _webView;  // [agl] ??? No call to makeFirstResponder:?
    }
    else
    {
        NSTextView *textView = [(NSScrollView *)currentSubview documentView];

        if ([[textView window] makeFirstResponder:textView])
        {
            return textView;
        }
        else
        {
            return nil;
        }
    }
}

#pragma mark -
#pragma mark AKViewController methods

- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo
{
    if ([whereTo isEqual:_docLocator])
    {
        return;
    }

    [self setDocLocator:whereTo];
    [self _updateDocDisplay];
}

#pragma mark -
#pragma mark Private methods

- (void)_updateDocDisplay
{
    if (_docLocator == nil)
    {
        return;
    }

    //  Figure out what text to display.
    AKDoc *docToDisplay = [_docLocator docToDisplay];
    AKFileSection *fileSection = [docToDisplay fileSection];
    NSString *htmlFilePath = [fileSection filePath];
    NSData *textData = [docToDisplay docTextData];

    // Display the text in either _textView or _webView.  Whichever it
    // is, swap it in as our subview if necessary.
    if ([docToDisplay isPlainText])
    {
        [self _useTextViewToDisplayPlainText:textData];

        // Make extra sure the cursor rects are updated so we get the
        // hand cursor over links.  Note: you'd think we should
        // invalidate the cursor rects for textView, but no, for some
        // reason it doesn't work unless we do it for scrollView.
        [[[self view] window] invalidateCursorRectsForView:[_textView enclosingScrollView]];
    }
    else
    {
        [self _useWebViewToDisplayHTML:textData fromFile:htmlFilePath];
    }
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
        docString = [[[NSString alloc] initWithData:textData
                                           encoding:NSUTF8StringEncoding] autorelease];
    }

    [_textView setRichText:NO];
    [_textView setFont:plainTextFont];

// Workaround for appkit bug (?) causing the last-used indentation
// level to stick to the text view even if I clear its contents and
// remove all its attributes.
// [agl] -- but, now it causes assert error?
//    [[_textView layoutManager] replaceTextStorage:[[NSTextStorage alloc] initWithString:@""]];

    [_textView setString:docString];
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
//        // [agl] TODO -- the wasKey stuff doesn't work
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

    [_webView setTextSizeMultiplier:multiplier];

    // Display the HTML in _webView.
    NSString *htmlString = @"";
    if (htmlData)
    {
        NSMutableData *zData = [NSMutableData dataWithData:htmlData];
        
        [zData setLength:([zData length] + 1)];
        htmlString = [NSString stringWithUTF8String:[zData bytes]];
    }

    if (htmlFilePath)
    {
        [[_webView mainFrame] loadHTMLString:htmlString
                                     baseURL:[NSURL fileURLWithPath:htmlFilePath]];
    }
    else
    {
        [[_webView mainFrame] loadHTMLString:htmlString baseURL:nil];
    }
}

//- (NSView *)focusOnDocView
//{
//    return [_docContainerView grabFocus];
//}



//#pragma mark -
//#pragma mark WebPolicyDelegate methods
//
//- (void)webView:(WebView *)sender
//decidePolicyForNavigationAction:(NSDictionary *)actionInformation
//        request:(NSURLRequest *)request
//          frame:(WebFrame *)frame
//decisionListener:(id <WebPolicyDecisionListener>)listener
//{
//    NSNumber *navType = [actionInformation objectForKey:WebActionNavigationTypeKey];
//    BOOL isLinkClicked = ((navType != nil)
//                          && ([navType intValue] == WebNavigationTypeLinkClicked));
//
//    if (isLinkClicked)
//    {
//        NSEvent *currentEvent = [NSApp currentEvent];
//        AKBrowserWindowController *wc = (([currentEvent modifierFlags] & NSCommandKeyMask)
//                                         ? [[NSApp delegate] controllerForNewWindow]
//                                         : [self browserWindowController]);
//
//        // Use a delayed perform to avoid mucking with the WebView's
//        // display while it's in the middle of processing a UI event.
//        // Note that the return value of -jumpToLinkURL: will be lost.
//        [wc performSelector:@selector(jumpToLinkURL:) withObject:[request URL] afterDelay:0];
//    }
//    else
//    {
//        [listener use];
//    }
//}
//
//#pragma mark -
//#pragma mark WebUIDelegate methods
//
//- (NSArray *)webView:(WebView *)sender
//contextMenuItemsForElement:(NSDictionary *)element
//    defaultMenuItems:(NSArray *)defaultMenuItems
//{
//    NSURL *linkURL = [element objectForKey:WebElementLinkURLKey];
//    NSMutableArray *newMenuItems = [NSMutableArray array];
//
//    // Don't have a contextual menu if there is nothing in the doc view.
//    if ([[self browserWindowController] currentDoc] == nil)
//    {
//        return newMenuItems;
//    }
//
//    // Loop through the proposed menu items in defaultMenuItems, and only
//    // allow certain ones of them to appear in the contextual menu, because
//    // the others don't make sense for us.
//    //
//    // Note that we may come across some tags for which there aren't
//    // WebMenuItemXXX constants declared in the version of WebKit
//    // I'm using.  For example, the "Reload" menu item has tag 12,
//    // which is WebMenuItemTagReload in newer versions of WebKit.
//    // That's okay -- as of this writing, none of those are things
//    // we want in the menu.
//    for (NSMenuItem *menuItem in defaultMenuItems)
//    {
//        NSInteger tag = [menuItem tag];
//
//        if (tag == WebMenuItemTagOpenLinkInNewWindow)
//        {
//            // Change this menu item so instead of opening the link
//            // in a new *web* browser window, it opens a new *AppKiDo*
//            // browser window.
//            [menuItem setAction:@selector(openLinkInNewWindow:)];
//            [menuItem setTarget:nil];  // will go to first responder
//            [menuItem setRepresentedObject:linkURL];
//
//            [newMenuItems addObject:menuItem];
//        }
//        else if ((tag == WebMenuItemTagCopyLinkToClipboard)
//                 || (tag == WebMenuItemTagDownloadImageToDisk)
//                 || (tag == WebMenuItemTagCopyImageToClipboard)
//                 || (tag == WebMenuItemTagCopyImageToClipboard)
//                 || (tag == WebMenuItemTagCopy))
//        {
//            [newMenuItems addObject:menuItem];
//        }
//    }
//
//    // Add an item to the menu that allows the user to copy the URL
//    // of the file being looked at to the clipboard.  The URL could
//    // then be pasted into an email message if the user is answering
//    // somebody's question on one of the dev lists, for example.  The
//    // URL could also be helpful for debugging.
//    NSMenuItem *copyURLItem = [[[NSMenuItem alloc] initWithTitle:@"Copy Page URL"
//                                                          action:@selector(copyDocTextURL:)
//                                                   keyEquivalent:@""] autorelease];
//    [copyURLItem setTarget:nil];  // will go to first responder
//    [newMenuItems addObject:copyURLItem];
//
//    // Add an item to the menu that allows the user to open the
//    // currently displayed file in the default web browser.
//    NSMenuItem *openURLInBrowserItem = [[[NSMenuItem alloc] initWithTitle:@"Open Page in Browser"
//                                                                   action:@selector(openDocURLInBrowser:)
//                                                            keyEquivalent:@""] autorelease];
//    [openURLInBrowserItem setTarget:nil];  // will go to first responder
//    [newMenuItems addObject:openURLInBrowserItem];
//
//    // Add an item to the menu that allows the user to reveal the
//    // currently displayed file in the Finder.
//    NSMenuItem *revealInFinderItem = [[[NSMenuItem alloc]initWithTitle:@"Reveal In Finder"
//                                                                action:@selector(revealDocFileInFinder:)
//                                                         keyEquivalent:@""] autorelease];
//    [revealInFinderItem setTarget:nil];  // will go to first responder
//    [newMenuItems addObject:revealInFinderItem];
//    
//    return newMenuItems;
//}
//

@end
