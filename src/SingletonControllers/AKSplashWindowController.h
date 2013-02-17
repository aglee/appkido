//
//  AKSplashWindowController.h
//  AppKiDo
//
//  Created by Andy Lee on 2/16/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AKDatabaseDelegate.h"

@interface AKSplashWindowController : NSWindowController <AKDatabaseDelegate>
{
@private
    NSTextField *_splashVersionField;
    NSTextField *_splashMessageField;
    NSTextField *_splashMessage2Field;
}

@property (nonatomic, retain) IBOutlet NSTextField *splashVersionField;
@property (nonatomic, retain) IBOutlet NSTextField *splashMessageField;
@property (nonatomic, retain) IBOutlet NSTextField *splashMessage2Field;

@end
