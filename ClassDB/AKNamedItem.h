//
//  AKNamedItem.h
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKNamedItem : NSObject
@property (copy) NSString *name;
/*! Defaults to self.name. */
@property (copy, readonly) NSString *sortName;
/*! Defaults to self.name.  A reason to override might be to add punctuation or other embellishment. */
@property (copy, readonly) NSString *displayName;
@end
