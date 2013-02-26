/*
 * DIGSFileProcessor.h
 *
 * Created by Andy Lee on Mon Jul 01 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

// [agl] behavior is applied to files, not dirnames; what about links?

/*!
 * Abstract class for iterating through files.
 *
 * To use a DIGSFileProcessor, call either -processFile: or
 * -processDirectory:recursively:, and it will iterate through the one or more
 * files you specified.  Directory recursion is optional, and your subclass can
 * optionally filter files by overriding -shouldProcessFile:.
 */
@interface DIGSFileProcessor : NSObject
{
@private
    NSString *_basePath;
    NSString *_currentPath;
}

@property (nonatomic, readonly, copy) NSString *basePath;
@property (nonatomic, readonly, copy) NSString *currentPath;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithBasePath:(NSString *)basePath;

#pragma mark -
#pragma mark Getters and setters

/*!
 * Returns the top-level path within which to find files to process. If this
 * path is a file, we will process that file. If it's a directory, we will
 * process the directory's contents, perhaps recursively.
 *
 * Default is the empty string. [agl] maybe nil would be better
 */
- (NSString *)basePath;

/*!
 * Returns the absolute path of the file I am currently processing, or nil if
 * I'm not in the middle of processing files.
 */
- (NSString *)currentPath;

#pragma mark -
#pragma mark Processing files

/*! Returns NO if the file should be ignored. The default is YES. */
- (BOOL)shouldProcessFile:(NSString *)filePath;

/*!
 * Checks whether the file at filePath satisfies the filter imposed by
 * -shouldProcessFile:. If so, calls -processCurrentFile.
 *
 * Do not override this.  Override -processCurrentFile instead.
 */
- (void)processFile:(NSString *)filePath;

/*!
 * Processes all files in the specified directory, subject to filtering by
 * -shouldProcessFile:. Recurses down subdirectories if recurseFlag is true.
 *
 * Changes the working directory to each directory it processes.
 *
 * Do not override this.
 */
- (void)processDirectory:(NSString *)dirPath recursively:(BOOL)recurseFlag;

/*!
 * Subclasses must override this to do whatever constitutes "processing" for
 * that subclass.
 *
 * This method is called by -processFile: and -processDirectory:recursively:.
 * Generally there's no reason for you to call this method directly.
 */
- (void)processCurrentFile;

@end
