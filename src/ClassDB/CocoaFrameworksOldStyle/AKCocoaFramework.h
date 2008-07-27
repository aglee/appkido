/*
 * AKCocoaFramework.h
 *
 * Created by Andy Lee on Tue May 10 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKFramework.h"

@interface AKCocoaFramework : AKFramework
{
    // Path name of the directory where the framework's header files live.
    NSString *_headerDir;

    // Path name of the directory where the framework's HTML
    // documentation files live.
    NSString *_mainDocDir;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

/*! Override... [agl] fill this in... may return nil */
+ (id)frameworkWithName:(NSString *)fwName;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

/*!
 * @method      headerDir
 * @discussion  Returns the path of the directory where the framework's
 *              header files are located.  There is no setter method;
 *              value is assigned by the init method.
 */
- (NSString *)headerDir;

/*!
 * @method      mainDocDir
 * @discussion  Returns the path of the directory where the framework's
 *              HTML documentation files live.  There is no setter method;
 *              value is assigned by the init method.
 */
- (NSString *)mainDocDir;

@end
