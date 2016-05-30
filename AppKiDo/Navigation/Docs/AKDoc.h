//
//  AKDoc.h
//  AppKiDo
//
//  Created by Andy Lee on 5/14/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamed.h"

@class AKDatabase;

/*!
 * Protocol adopted by objects that can be listed in the doc list.  When the
 * object's row is selected in the doc list, the object provides a string to
 * display in the comment field at the bottom of the window, and also provides
 * a URL for the content that should be displayed in the doc view.
 */
@protocol AKDoc <AKNamed>

@required

/*! Displayed in the comment field at the bottom of the window. */
@property (copy, readonly) NSString *commentString;

- (NSURL *)docURLAccordingToDatabase:(AKDatabase *)database;

@end
