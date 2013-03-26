//
//  AKPopQuizWindowController.m
//  AppKiDo
//
//  Created by Andy Lee on 3/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKPopQuizWindowController.h"

#import "AKAppDelegate.h"
#import "AKDatabase.h"
#import "AKDocLocator.h"
#import "AKRandomSearch.h"

@implementation AKPopQuizWindowController

@synthesize symbolNameField = _symbolNameField;

+ (AKDocLocator *)showPopQuiz
{
    // Select a random doc.
    AKDatabase *db = [(AKAppDelegate *)[NSApp delegate] appDatabase];
    AKRandomSearch *randomSearch = [[[AKRandomSearch alloc] initWithDatabase:db] autorelease];
    AKDocLocator *docLocator = [randomSearch randomDocLocator];

    // The NSFont docs say U200B is Unicode for ZERO WIDTH SPACE. We do this so
    // that if we get a long method name, word wrap will be after the colons.
    NSString *docName = [[docLocator docName] stringByReplacingOccurrencesOfString:@":"
                                                                        withString:@":\u200B"];

    // Display the doc name and let the user ponder what it means.
    AKPopQuizWindowController *wc = [[[self alloc] initWithWindowNibName:@"PopQuiz"] autorelease];
    
    [[wc window] center];  // Forces the nib to be loaded, so symbolNameField gets set.
    [[wc symbolNameField] setSelectable:YES];
    [[wc symbolNameField] setStringValue:docName];

    (void)[[NSApplication sharedApplication] runModalForWindow:[wc window]];

    // Return the doc we chose.
    return docLocator;
}

#pragma mark -
#pragma mark Action methods

- (IBAction)ok:(id)sender
{
    [[NSApplication sharedApplication] stopModal];
    [[self window] orderOut:self];
}

@end
