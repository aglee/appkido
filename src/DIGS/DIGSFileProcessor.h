/*
 * DIGSFileProcessor.h
 *
 * Created by Andy Lee on Mon Jul 01 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

// [agl] behavior is applied to files, not dirnames; what about links?

/*!
 * @class       DIGSFileProcessor
 * @abstract    Abstract class for iterating through files.
 * @discussion  To use a DIGSFileProcessor, call either -processFile: or
 *              -processDirectory:recursively:, and it will iterate
 *              through the one or more files you specified.  Directory
 *              recursion is optional, and your subclass can optionally
 *              filter files by overriding -shouldProcessFile:.
 */
@interface DIGSFileProcessor : NSObject
{
@private
    NSString *_basePath;
    NSString *_currentPath;
}


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithBasePath:(NSString *)basePath;

/*! Returns [self -initWithBasePath:@""]. */
- (id)init;


#pragma mark -
#pragma mark Getters and setters

/*!
 * @method      basePath
 * @discussion  Returns the basePath within which to find files to process.
 *              Default is the empty string.
 */
- (NSString *)basePath;

/*!
 * @method      currentPath
 * @discussion  Returns nil if I am not in the middle of processing files.
 *              Otherwise, returns the absolute path of the file I am
 *              currently processing.  
 */
- (NSString *)currentPath;


#pragma mark -
#pragma mark Processing files

/*!
 * @method      shouldProcessFile:
 * @discussion  Returns YES (the default) if I should process the
 *              specified file, NO if I should ignore it.  Subclasses can
 *              optionally override this as a way of filtering files.
 */
- (BOOL)shouldProcessFile:(NSString *)filePath;

/*!
 * @method      processFile:
 * @discussion  Processes the specified file, if it satisfies the filter
 *              imposed by -shouldProcessFile:.  filePath must be relative to
 *              the receiver's basePath (which might be the empty string).
 *
 *              Do not override this.  Override -processCurrentFile instead.
 */
- (void)processFile:(NSString *)filePath;

/*!
 * @method      processDirectory:recursively:
 * @discussion  Processes all files in the specified directory, subject
 *              to filtering by -shouldProcessFile:.  Recurses down
 *              subdirectories if recurseFlag is YES.
 *
 *              This method changes the working directory to each directory
 *              it processes.
 *
 *              Do not override this.
 */
- (void)processDirectory:(NSString *)dirPath recursively:(BOOL)recurseFlag;

/*!
 * @method      processCurrentFile
 * @discussion  Subclasses must override this to do whatever constitutes
 *              "processing" for that subclass.
 *
 *              This method is called by -processFile: and
 *              -processDirectory:recursively:.  Generally there's no reason to
 *              call this method directly.  
 */
- (void)processCurrentFile;

@end
