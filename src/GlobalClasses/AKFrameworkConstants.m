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
                AKAppKitFrameworkName,
                AKUIKitFrameworkName,
                AKCoreDataFrameworkName,
                AKCoreImageFrameworkName,
                AKQuartzCoreFrameworkName,
                //@"ApplicationServices",
                nil] retain];
    }

    return s_namesOfEssentialFrameworks;
}
