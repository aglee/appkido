//
//  AKPopQuizWindowController.h
//  AppKiDo
//
//  Created by Andy Lee on 3/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKDocLocator;

@interface AKPopQuizWindowController : NSWindowController
{
@private
    NSString *_chosenAPISymbol;

    // IBOutlets.
    NSTextField *_symbolNameField;
}

@property (nonatomic, strong) IBOutlet NSTextField *symbolNameField;

+ (void)showPopQuiz;

#pragma mark - Action methods

- (IBAction)okPopQuiz:(id)sender;

- (IBAction)cancelPopQuiz:(id)sender;

- (IBAction)pickAnother:(id)sender;

@end
