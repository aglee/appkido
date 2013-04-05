//
//  AKPopQuizWindowController.m
//  AppKiDo
//
//  Created by Andy Lee on 3/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKPopQuizWindowController.h"

#import "AKAppDelegate.h"
#import "AKRandomSearch.h"
#import "AKWindowController.h"

@interface AKPopQuizWindowController ()
@property (nonatomic, copy) NSString *chosenAPISymbol;
@end

@implementation AKPopQuizWindowController

@synthesize chosenAPISymbol = _chosenAPISymbol;
@synthesize symbolNameField = _symbolNameField;
@synthesize pickAnotherButton = _pickAnotherButton;

+ (void)showPopQuiz
{
    AKPopQuizWindowController *wc = [[[self alloc] initWithWindowNibName:@"PopQuiz"] autorelease];
    
    [[wc window] center];
    [[wc symbolNameField] setSelectable:YES];
    [[wc pickAnotherButton] setEnabled:NO];
    [[wc pickAnotherButton] setEnabled:YES];
    
    [wc _chooseRandomAPISymbol];

    (void)[[NSApplication sharedApplication] runModalForWindow:[wc window]];
}

#pragma mark -
#pragma mark Action methods

- (IBAction)okPopQuiz:(id)sender
{
    [[NSApplication sharedApplication] stopModal];
    [[self window] orderOut:self];

    [self _revealDocsForChosenAPISymbol];
}

- (IBAction)cancelPopQuiz:(id)sender
{
    [[NSApplication sharedApplication] abortModal];
    [[self window] orderOut:self];
}

- (IBAction)pickAnother:(id)sender
{
    [self _chooseRandomAPISymbol];
}

#pragma mark -
#pragma mark Private methods

- (void)_chooseRandomAPISymbol
{
    // Choose a random API symbol.
    AKDatabase *db = [[AKAppDelegate appDelegate] appDatabase];
    AKRandomSearch *randomSearch = [AKRandomSearch randomSearchWithDatabase:db];
    NSString *apiSymbol = [randomSearch selectedAPISymbol];

    [self setChosenAPISymbol:apiSymbol];

    // Display the symbol. We insert zero-width spaces so that if we get a long
    // method name that word-wraps, line breaks will be after the colons. The
    // NSFont docs say U200B is Unicode for ZERO WIDTH SPACE.
    NSString *symbolModifiedForDisplay = [apiSymbol stringByReplacingOccurrencesOfString:@":"
                                                                              withString:@":\u200B"];
    [[self symbolNameField] setStringValue:symbolModifiedForDisplay];
}

- (void)_revealDocsForChosenAPISymbol
{
    AKWindowController *wc = [[AKAppDelegate appDelegate] frontmostWindowController];

    if (wc == nil)
    {
        wc = [[AKAppDelegate appDelegate] controllerForNewWindow];
    }

    [wc revealPopQuizSymbol:[self chosenAPISymbol]];
}

@end
