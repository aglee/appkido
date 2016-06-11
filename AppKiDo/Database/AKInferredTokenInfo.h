//
//  AKInferredTokenInfo.h
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DSAToken;

/*!
 * Tries to infer what a node is about, purely from the words in the node name.
 * Purely a string parser.  Doesn't validate, for example, whether a framework
 * named frameworkName exists in the database, or a class named nameOfClass,
 * etc.
 */
@interface AKInferredTokenInfo : NSObject

@property (strong, readonly) DSAToken *tokenMO;
@property (copy, readonly) NSString *nodeName;

/*! For "Foundation Constants Reference" this would be "Foundation". */
@property (copy) NSString *frameworkName;

/*! For "Foundation Constants Reference" this would be "Constants". */
@property (copy, readonly) NSString *frameworkChildTopicName;

/*!
 * For "AVPlayerItem Class Reference" this would be "AVPlayerItem".  Property is
 * named nameOfClass to avoid conflict with [NSObject className].
 */
@property (copy, readonly) NSString *nameOfClass;

/*!
 * For "NSAccessibility Protocol Reference" or "NSAccessibility Informal
 * Protocol Reference" this would be "NSAccessibility".
 */
@property (copy, readonly) NSString *nameOfProtocol;

/*! For "DRSetupPanel.h Reference" this would be "DRSetupPanel.h". */
@property (copy, readonly) NSString *headerFileName;

/*! For "Keychain Services Reference" this would be "Keychain Services". */
@property (copy, readonly) NSString *nodeSubject;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO;

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
