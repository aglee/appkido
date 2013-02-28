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

- (void)searchForStringInPasteboard:(NSPasteboard *)pboard
                  extractMethodName:(BOOL)shouldExtractMethodName
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
    
    if (shouldExtractMethodName)
    {
        NSString *methodName = [AKMethodNameExtractor extractMethodNameFromString:searchString];
        if (methodName)
        {
            searchString = methodName;
        }
    }
    
    // Perform the requested search.
    [(AKAppDelegate *)[NSApp delegate] searchForString:searchString];
}

#pragma mark -
#pragma mark Methods listed in the NSServices section of Info.plist

- (void)searchForString:(NSPasteboard *)pboard
               userData:(NSString *)userData
                  error:(NSString **)errorMessagePtr
{
    [self searchForStringInPasteboard:pboard extractMethodName:NO error:errorMessagePtr];
}

- (void)searchForMethod:(NSPasteboard *)pboard
               userData:(NSString *)userData
                  error:(NSString **)errorMessagePtr
{
    [self searchForStringInPasteboard:pboard extractMethodName:YES error:errorMessagePtr];
}

@end
