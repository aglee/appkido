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
 * nil or detect a loop.  Uses nextObjectKeyPath to get each object's successor
 * in the sequence.
 */
- (void)ak_printSequenceWithValuesForKeyPaths:(NSArray *)keyPathsToPrint
							nextObjectKeyPath:(NSString *)nextObjectKeyPath;

/*!
 * Logs a tab-indented outline representing a tree rooted at self.  Uses
 * childObjectsKeyPath to get the children of each object in the tree.
 *
 * TODO: Handle cycles.
 */
- (void)ak_printTreeWithValuesForKeyPaths:(NSArray *)keyPathsToPrint
					  childObjectsKeyPath:(NSString *)childObjectsKeyPath;

@end
