//
//  NSObject+AppKiDo.h
//  AppKiDo
//
//  Created by Andy Lee on 3/10/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AppKiDo)

/*! Of the form <NSTableView: 0x179a770>, and nothing else. */
@property (readonly, copy) NSString *ak_bareDescription;

/*!
 * Logs a sequence of objects starting at self and ending when we either hit
 * nil or detect a loop. Sends nextObjectSelector to each object to get the next
 * object in the sequence.
 */
- (void)ak_printSequenceUsingSelector:(SEL)nextObjectSelector;  //TODO: A block-based version might be nice.

- (void)ak_printTreeWithSelfKeyPaths:(NSArray *)selfKeyPaths
				 childObjectsKeyPath:(NSString *)childObjectsKeyPath;

@end
