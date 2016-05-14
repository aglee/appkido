//
//  AKNamedObject.h
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKSortable.h"

@class DocSetIndex;

@interface AKNamedObject : NSObject <AKSortable>

@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *displayName;

- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

/*!
 * The string to display in the comment field at the bottom of the window.
 * Defaults to the empty string.
 */
@property (copy, readonly) NSString *commentString;

- (NSURL *)docURLAccordingToDocSetIndex:(DocSetIndex *)docSetIndex;

@end
