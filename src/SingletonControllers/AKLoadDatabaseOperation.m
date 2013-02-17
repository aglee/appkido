//
//  AKLoadDatabaseOperation.m
//  AppKiDo
//
//  Created by Andy Lee on 2/16/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKLoadDatabaseOperation.h"

#import "AKAppController.h"
#import "AKDatabase.h"
#import "AKPrefUtils.h"

#import "DIGSLog.h"

@implementation AKLoadDatabaseOperation

#pragma mark - Init/awake/dealloc

- (void)dealloc
{
    [_appDatabase release];
    _databaseDelegate = nil;

    [super dealloc];
}

#pragma mark - NSOperation methods

- (void)main
{
    [_appDatabase setDelegate:self];
    {{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AKFoundationOnly"])
        {
            // Special debug mode so launch is quicker.
            // defaults write com.digitalspokes.appkido AKFoundationOnly YES  # or NO
            // defaults write com.appkido.appkidoforiphone AKFoundationOnly YES  # or NO
            [_appDatabase loadTokensForFrameworks:[NSArray arrayWithObject:@"Foundation"]];
        }
        else
        {
            [_appDatabase loadTokensForFrameworks:[AKPrefUtils selectedFrameworkNamesPref]];
        }
    }}
    [_appDatabase setDelegate:nil];

    [self performSelectorOnMainThread:@selector(_finishOnMainThread)
                           withObject:nil
                        waitUntilDone:NO];
}

#pragma mark - AKDatabase delegate methods

- (void)database:(AKDatabase *)database willLoadTokensForFramework:(NSString *)frameworkName
{
    [self performSelectorOnMainThread:@selector(_tellDelegateWillLoadTokensForFramework:)
                           withObject:frameworkName
                        waitUntilDone:NO];
}

#pragma mark - Private methods

// Gets called on the main thread as the last thing this operation does.
- (void)_finishOnMainThread
{
    [(AKAppController *)[NSApp delegate] didFinishLoadingDatabase];
}

- (void)_tellDelegateWillLoadTokensForFramework:(NSString *)frameworkName
{
    if ([(id)_databaseDelegate respondsToSelector:@selector(database:willLoadTokensForFramework:)])
    {
        [_databaseDelegate database:_appDatabase willLoadTokensForFramework:frameworkName];
    }
}

@end
