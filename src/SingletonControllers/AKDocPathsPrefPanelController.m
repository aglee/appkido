//
//  AKDocPathsPrefPanelController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDocPathsPrefPanelController.h"

#import "DIGSLog.h"
#import "AKPrefUtils.h"


@implementation AKDocPathsPrefPanelController

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKDocPathsPrefPanelController *)sharedInstance
{
    static AKDocPathsPrefPanelController *s_sharedInstance = nil;

    if (!s_sharedInstance)
    {
        s_sharedInstance = [[self alloc] init];
    }

    return s_sharedInstance;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)init
{
    if ((self = [super init]))
    {
        if (![NSBundle loadNibNamed:@"DocPathsPrefPanel" owner:self])
        {
            DIGSLogDebug(@"Failed to load DocPathsPrefPanel.nib");
            [self release];
            return nil;
        }
    }

    return self;
}

- (void)awakeFromNib
{
    // Get values from the user's prefs and stick them into the UI.
}

//-------------------------------------------------------------------------
// Running the panel
//-------------------------------------------------------------------------

- (BOOL)runPanel
{
    return YES;
}

@end
