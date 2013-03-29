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
    NSTextField *_symbolNameField;
}

@property (nonatomic, strong) IBOutlet NSTextField *symbolNameField;

+ (void)showPopQuizWithAPISymbol:(NSString *)apiSymbol;

#pragma mark -
#pragma mark Action methods

- (IBAction)ok:(id)sender;

@end
