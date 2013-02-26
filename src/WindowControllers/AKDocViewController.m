//
//  AKDocViewController.m
//  AppKiDo
//
//  Created by Andy Lee on 2/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKDocViewController.h"

@interface AKDocViewController ()

@end

@implementation AKDocViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}




//- (NSView *)focusOnDocView
//{
//    return [_docView grabFocus];
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
