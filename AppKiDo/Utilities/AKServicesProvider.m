//
//  AKServicesProvider.m
//  AppKiDo
//
//  Created by Andy Lee on 7/16/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import "AKServicesProvider.h"

#import "AKAppDelegate.h"
#import "AKMethodNameExtractor.h"
#import "AKWindowController.h"

@implementation AKServicesProvider

#pragma mark - Methods listed in the NSServices section of Info.plist

// "copyWithSelectorAwareness" is what appears in Info.plist. The rest of the
// method name is implied.
- (void)copyWithSelectorAwareness:(NSPasteboard *)pboard
                         userData:(NSString *)userData
                            error:(NSString **)errorMessagePtr
{
    // Make sure the pasteboard contains a string.
    if (![pboard canReadObjectForClasses:@[[NSString class]] options:@{}])
    {
        *errorMessagePtr = NSLocalizedString(@"Error: the pasteboard doesn't contain a string.", nil);
        return;
    }

    // Get the string from the pasteboard.
    NSString *pasteboardString = [pboard stringForType:NSPasteboardTypeString];
    NSString *methodName = [AKMethodNameExtractor extractMethodNameFromString:pasteboardString];

    if (methodName)
    {
        pasteboardString = methodName;
    }

    // Stuff the extracted method name, or the original string if none, into the
    // system-wide copy/paste pasteboard.
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    
    [generalPasteboard declareTypes:@[NSStringPboardType] owner:nil];
    [generalPasteboard setString:pasteboardString forType:NSStringPboardType];
}

- (void)searchForMethod:(NSPasteboard *)pboard
               userData:(NSString *)userData
                  error:(NSString **)errorMessagePtr
{
    // Make sure the pasteboard contains a string.
    if (![pboard canReadObjectForClasses:@[[NSString class]] options:@{}])
    {
        *errorMessagePtr = NSLocalizedString(@"Error: the pasteboard doesn't contain a string.", nil);
        return;
    }

    // Get the search string from the pasteboard.
    NSString *searchString = [pboard stringForType:NSPasteboardTypeString];
    NSString *methodName = [AKMethodNameExtractor extractMethodNameFromString:searchString];

    if (methodName)
    {
        searchString = methodName;
    }

    // Perform the requested search.
    [[AKAppDelegate appDelegate] performExternallyRequestedSearchForString:searchString];
}

@end
