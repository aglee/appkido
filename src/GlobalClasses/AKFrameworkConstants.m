/*
 * AKFrameworkConstants.m
 *
 * Created by Andy Lee on Wed Mar 31 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFrameworkConstants.h"

//-------------------------------------------------------------------------
// AKXyzFrameworkName
//-------------------------------------------------------------------------

NSString *AKFoundationFrameworkName  = @"Foundation";
NSString *AKAppKitFrameworkName      = @"AppKit";
NSString *AKUIKitFrameworkName       = @"UIKit";
NSString *AKCoreDataFrameworkName    = @"CoreData";
NSString *AKCoreImageFrameworkName   = @"CoreImage";
NSString *AKQuartzCoreFrameworkName  = @"QuartzCore";

NSArray *_AKNamesOfEssentialFrameworks()
{
    static NSArray *s_namesOfEssentialFrameworks = nil;

    if (s_namesOfEssentialFrameworks == nil)
    {
        s_namesOfEssentialFrameworks =
            [[NSArray arrayWithObjects:
                AKFoundationFrameworkName,
#if APPKIDO_FOR_IPHONE
                AKUIKitFrameworkName,
#else
                AKAppKitFrameworkName,
                AKCoreDataFrameworkName,
#endif
                AKCoreImageFrameworkName,
                AKQuartzCoreFrameworkName,
#if APPKIDO_FOR_IPHONE
                @"CoreGraphics",  // [agl] KLUDGE -- to get CGPoint etc.
#else
                @"ApplicationServices",  // [agl] KLUDGE -- to get CGPoint etc.
#endif
                nil] retain];
    }

    return s_namesOfEssentialFrameworks;
}
