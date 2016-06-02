/*
 * DIGSFileProcessor.h
 *
 * Created by Andy Lee on Mon Jul 01 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

//TODO: What about links and aliases?

//TODO: Any reason to use this rather than NSDirectoryEnumerator?

/*!
 * No-frills class for iterating through files.  rootPath may be either a file
 * or a directory.
 */
@interface DIGSFileProcessor : NSObject

#pragma mark - Processing files

- (void)processRootPath:(NSString *)rootPath;

/*!
 * You don't call this, you override it.  Default implementation processes each
 * item in the directory.  Subclasses should call super if they want to recurse.
 */
- (void)processDirectoryAtPath:(NSString *)dirPath depth:(NSInteger)depth;

/*! You don't call this, you override it.  Default implementation does nothing. */
- (void)processFileAtPath:(NSString *)filePath depth:(NSInteger)depth;

@end
