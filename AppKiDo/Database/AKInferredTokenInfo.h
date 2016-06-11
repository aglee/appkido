//
//  AKInferredTokenInfo.h
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKInferredFrameworkInfo.h"

@class DSAToken;

/*!
 * In addition to what AKInferredFrameworkInfo does, tries to infer what the
 * relevant behavior is for the given tokenMO.  Does not try to figure out
 * whether a category is actually an informal protocol -- it's up to the caller
 * to do that.
 */
@interface AKInferredTokenInfo : AKInferredFrameworkInfo

/*!
 * For "AVPlayerItem Class Reference" this would be "AVPlayerItem".  Property is
 * named nameOfClass to avoid conflict with [NSObject className].
 */
@property (readonly) NSString *nameOfClass;

/*!
 * Gets set when we come across a node name of the form
 * "CLASSNAME(CATEGORYNAME) Class Reference".  An example from the macOS 10.11.4
 * docset is "DRBurn(ImageContentCreation) Class Reference".  We don't try to
 * tell out if the category is actually an informal protocol -- it's up to the
 * caller to figure that out if it needs to.
 */
@property (readonly) NSString *nameOfCategory;

/*!
 * For "NSAccessibility Protocol Reference" or "NSAccessibility Informal
 * Protocol Reference" this would be "NSAccessibility".
 */
@property (readonly) NSString *nameOfProtocol;

/*!
 * What the node is "about".  This may be used, for example, as a group name for
 * "functions and globals" tokens.
 *
 * For "Keychain Services Reference" this would be "Keychain Services".
 */
@property (readonly) NSString *nodeSubject;

#pragma mark - Parsing

/*!
 * The returned dictionary will have one of the following forms:
 *
 * - class name and category name
 *   - input is @"CLASSNAME(CATEGORYNAME)"
 *   - output is @{ @1 : @"CLASSNAME", @2 : @"CATEGORYNAME" }
 *
 * - class name only
 *   - input is @"CLASSNAME"
 *   - output is @{ @1 : @"CLASSNAME" }
 *
 * - any other input causes nil to be returned
 */
+ (NSDictionary *)parsePossibleCategoryName:(NSString *)name;

@end
