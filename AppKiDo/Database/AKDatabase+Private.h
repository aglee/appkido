//
//  AKDatabase+Private.h
//  AppKiDo
//
//  Created by Andy Lee on 5/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase.h"
#import "AKBehaviorInfo.h"
#import "AKBehaviorToken.h"
#import "DocSetModel.h"

/*!
 * This header should only be imported by the .m files for AKDatabase and its
 * categories.
 */
@interface AKDatabase ()
// "Private" properties.
@property (strong, readonly) AKNamedObjectGroup *frameworksGroup;
@property (copy, readonly) NSMutableDictionary *classTokensByName;
@property (copy, readonly) NSMutableDictionary *protocolTokensByName;
@end

#pragma mark -

@interface AKDatabase (ImportUtils)

- (AKManagedObjectQuery *)_queryWithEntityName:(NSString *)entityName;
- (NSArray *)_fetchTokenMOsWithLanguage:(NSString *)languageName tokenType:(NSString *)tokenType;

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
- (NSDictionary *)_parsePossibleCategoryName:(NSString *)name;

@end

#pragma mark -

@interface AKDatabase (ImportFrameworks)

- (void)_importFrameworks;
- (AKFramework *)_getOrAddFrameworkWithName:(NSString *)frameworkName;

@end

#pragma mark -

@interface AKDatabase (ImportObjC)

/*!
 * Scans tokens in the DocSetIndex tagged with "Objective-C" as their language.
 * Adds AKToken objects to the database accordingly.  This means:
 *
 * - Behaviors (my umbrella word for protocols, classes, and categories).
 * - Members (my umbrella word for properties, methods, and bindings).
 */
- (void)_importObjectiveCTokens;

- (AKProtocolToken *)_getOrAddProtocolTokenWithName:(NSString *)protocolName;
- (AKClassToken *)_getOrAddClassTokenWithName:(NSString *)className;

@end

#pragma mark -

@interface AKDatabase (ImportC)

/*
 * Scans tokens in the DocSetIndex tagged with "C" as their language.  Adds
 * AKToken objects to the database accordingly.  This means C functions,
 * constants, macros (i.e. #defines), enums, and typedefs.  My umbrella term for
 * these token categories is "functions and globals".
 *
 * These categories overlap.  For example, some macros are classified like
 * functions and some like constants.
 *
 * Some constants are NSStrings, so they're not technically "C".  This is a
 * harmless misnomer as far as AppKiDo is concerned.
 *
 * Some globals are documented along with classes and protocols they are closely
 * associated with.  For example, the documentation page for NSWindow has
 * sections for "Data Types", "Constants", and "Notifications".  These tokens
 * are added as pseudo-members of the class or protocol.  All other functions
 * and globals are grouped with the framework they belong to.
 */
- (void)_importCTokens;

@end

#pragma mark -

@interface AKDatabase (InferringFramework)
- (AKFramework *)_frameworkForTokenMO:(DSAToken *)tokenMO;
@end

#pragma mark -

@interface AKDatabase (InferringBehavior)
- (AKBehaviorToken *)_behaviorTokenFromInferredInfo:(AKBehaviorInfo *)behaviorInfo;
- (AKBehaviorInfo *)_behaviorInfoInferredFromTokenMO:(DSAToken *)tokenMO;
@end

