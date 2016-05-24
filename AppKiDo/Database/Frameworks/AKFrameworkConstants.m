/*
 * AKFrameworkConstants.m
 *
 * Created by Andy Lee on Wed Mar 31 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFrameworkConstants.h"

#pragma mark - Frameworks that we give special treatment

NSString *AKFoundationFrameworkName  = @"Foundation";
NSString *AKAppKitFrameworkName      = @"AppKit";
NSString *AKUIKitFrameworkName       = @"UIKit";
NSString *AKCoreDataFrameworkName    = @"CoreData";
NSString *AKCoreImageFrameworkName   = @"CoreImage";
NSString *AKQuartzCoreFrameworkName  = @"QuartzCore";

NSArray *_AKNamesOfEssentialFrameworks()
{
	static NSArray *s_namesOfEssentialFrameworks = nil;
	static dispatch_once_t once;
	dispatch_once(&once,^{
		s_namesOfEssentialFrameworks = @[
										 AKFoundationFrameworkName,
#if APPKIDO_FOR_IPHONE
										 @"CoreGraphics",  //TODO: KLUDGE -- to get CGPoint etc.
										 AKUIKitFrameworkName,
#else
										 @"ApplicationServices",  //TODO: KLUDGE -- to get CGPoint etc.
										 AKAppKitFrameworkName,
										 AKCoreDataFrameworkName,
										 AKCoreImageFrameworkName,
#endif
										 AKQuartzCoreFrameworkName,
										 ];
	});

	return s_namesOfEssentialFrameworks;
}
