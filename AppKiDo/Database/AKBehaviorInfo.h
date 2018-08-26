//
//  AKBehaviorInfo.h
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKBehaviorInfo : NSObject

/*!
 * For "AVPlayerItem Class Reference" this would be "AVPlayerItem".  Property is
 * named nameOfClass to avoid conflict with [NSObject className].
 */
@property (copy) NSString *nameOfClass;

/*!
 * Gets set when we come across a node name of the form
 * "CLASSNAME(CATEGORYNAME) Class Reference".  An example from the macOS 10.11.4
 * docset is "DRBurn(ImageContentCreation) Class Reference".  We don't try to
 * tell out if the category is actually an informal protocol -- it's up to the
 * caller to figure that out if it needs to.
 */
@property (copy) NSString *nameOfCategory;

/*!
 * For "NSAccessibility Protocol Reference" or "NSAccessibility Informal
 * Protocol Reference" this would be "NSAccessibility".
 */
@property (copy) NSString *nameOfProtocol;

@end
