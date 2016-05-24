//
//  AKTokenInferredInfo.h
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocSetModel.h"

@class AKBehaviorToken;
@class AKDatabase;
@class AKFramework;

/*!
 * Deconstructs node names to try to infer what the node is about -- what's the
 * relevant framework, class, protocol, etc.
 */
@interface AKTokenInferredInfo : NSObject

@property (copy) NSString *nodeName;

/*! For "Foundation Constants Reference" this would be the Foundation framework. */
@property (strong) AKFramework *framework;

/*! For "Foundation Constants Reference" this would be "Constants". */
@property (copy, readonly) NSString *frameworkChildTopicName;

/*!
 * For "AVPlayerItem Class Reference" this would be "AVPlayerItem".
 * For "NSAccessibility Protocol Reference" this would be "NSAccessibility".
 */
@property (strong, readonly) AKBehaviorToken *behaviorToken;

/*! For "DRSetupPanel.h Reference" this would be "DRSetupPanel.h". */
@property (copy, readonly) NSString *headerFileName;

/*! For "Keychain Services Reference" this would be "Keychain Services". */
@property (copy, readonly) NSString *referenceSubject;

#pragma mark - Init/awake/dealloc

/*!
 * The provided AKDatabase gives context for checking whether a given word in
 * the node name is a framework name, a class name, a protocol name, or none of
 * the above.
 */
- (instancetype)initWithTokenMO:(DSAToken *)tokenMO database:(AKDatabase *)database;

@end
