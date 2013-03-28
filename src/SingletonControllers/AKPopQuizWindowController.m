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
#import "AKDatabaseNode.h"
#import "AKDocLocator.h"
#import "AKRandomSearch.h"
#import "AKTopic.h"

@implementation AKPopQuizWindowController

@synthesize symbolNameField = _symbolNameField;

+ (NSString *)showPopQuiz
{
    // Select a random API symbol.
    AKDatabase *db = [(AKAppDelegate *)[NSApp delegate] appDatabase];
    AKRandomSearch *randomSearch = [[[AKRandomSearch alloc] initWithDatabase:db] autorelease];
    NSString *symbol = [randomSearch randomAPISymbol];

    // The NSFont docs say U200B is Unicode for ZERO WIDTH SPACE. We do this so
    // that if we get a long method name, word wrap will be after the colons.
    NSString *adjustedSymbol = [symbol stringByReplacingOccurrencesOfString:@":" withString:@":\u200B"];

    // Display the symbol and let the user ponder what it means. Note that
    // calling [wc window] forces the nib to be loaded, guaranteeing the
    // symbolNameField outlet gets connected before we attempt to message it.
    AKPopQuizWindowController *wc = [[[self alloc] initWithWindowNibName:@"PopQuiz"] autorelease];
    
    [[wc window] center];
    [[wc symbolNameField] setSelectable:YES];
    [[wc symbolNameField] setStringValue:adjustedSymbol];

    (void)[[NSApplication sharedApplication] runModalForWindow:[wc window]];

    // Return the symbol we chose.
    return symbol;
}

#pragma mark -
#pragma mark Action methods

- (IBAction)ok:(id)sender
{
    [[NSApplication sharedApplication] stopModal];
    [[self window] orderOut:self];
}

@end
