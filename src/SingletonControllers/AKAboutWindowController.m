//
//  AKAboutWindowController.m
//  AppKiDo
//
//  Created by Andy Lee on 7/13/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import "AKAboutWindowController.h"
#import <WebKit/WebKit.h>
#import "AKAppVersion.h"
#import "AKViewUtils.h"

@implementation AKAboutWindowController

#pragma mark - NSWindowController methods

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Load the credits file into the web view.
    NSString *creditsPath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
    NSError *err = nil;
    NSString *creditsString = [NSString stringWithContentsOfFile:creditsPath
                                                        encoding:NSUTF8StringEncoding
                                                           error:&err];
    if (creditsString == nil)
    {
        NSLog(@"Error loading credits file from [%@] - [%@]", creditsPath, err);
    }
    else
    {
        NSString *versionString = [[AKAppVersion appVersion] displayString];
        
        creditsString = [creditsString stringByReplacingOccurrencesOfString:@"$APPVERSION"
                                                                 withString:versionString];
        [[_creditsView mainFrame] loadHTMLString:creditsString baseURL:nil];
    }
}

#pragma mark -
#pragma mark WebFrameLoadDelegate methods

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    // I had this in windowDidLoad and it wasn't affecting elasticity. Learned
    // on StackOverflow that I should do it here, which makes sense because the
    // WebView may change elasticity during the course of loading content.
    // <http://stackoverflow.com/questions/11170038/remove-elasticity-from-webview>
    [_creditsView ak_removeAllElasticity];
}

#pragma mark -
#pragma mark WebPolicyDelegate methods

- (void)webView:(WebView *)sender
decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
          frame:(WebFrame *)frame
decisionListener:(id <WebPolicyDecisionListener>)listener
{
    NSNumber *navType = [actionInformation objectForKey:WebActionNavigationTypeKey];
    BOOL isLinkClicked = ((navType != nil) && ([navType intValue] == WebNavigationTypeLinkClicked));
    
    if (isLinkClicked)
    {
        // Use a delayed perform to avoid mucking with the WebView's
        // display while it's in the middle of processing a UI event.
        // Note that the return value of -jumpToLinkURL: will be lost.
        [[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:)
                                            withObject:[request URL]
                                            afterDelay:0];
    }
    else
    {
        [listener use];
    }
}

@end
