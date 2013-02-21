/*
 * AKParser.h
 *
 * Created by Andy Lee on Sat Mar 06 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSFileProcessor.h"

@class AKFramework;

// [agl] add checks for buffer overflow
#define AKParserTokenBufferSize 1024

/*!
 * Abstract base class for parsers used to populate the AppKiDo database.
 *
 * An AKParser parses files that contain API information, creates database nodes
 * that encapsulate that information, and inserts the nodes into an AKDatabase.
 *
 * A given instance of AKParser targets one specific framework.
 *
 * Each subclass of AKParser parses a particular type of file. Subclasses must
 * override -parseCurrentFile, and must NOT override -processCurrentFile.
 *
 * Three protected instance variables -- _dataStart, _current, and _dataEnd --
 * can be used by subclasses in their -parseCurrentFile methods. See
 * -parseCurrentFile for details.
 */
@interface AKParser : DIGSFileProcessor
{
@protected
    AKFramework *_targetFramework;

    // These protected ivars are only used during parsing.  They point to
    // various positions in the data being parsed.
    const char *_dataStart;
    const char *_current;
    const char *_dataEnd;
}


#pragma mark -
#pragma mark Class methods

+ (void)recursivelyParseDirectory:(NSString *)dirPath
                     forFramework:(AKFramework *)aFramework;

+ (void)parseFilesInSubpaths:(NSArray *)subpaths
                underBaseDir:(NSString *)baseDir
                forFramework:(AKFramework *)aFramework;


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithFramework:(AKFramework *)aFramework;


#pragma mark -
#pragma mark Parsing

/*!
 * Used internally by -parseCurrentFile. By default, returns the contents of
 * [self currentPath].
 *
 * Do not call this method directory.  Subclasses can override it if they want
 * to modify the data before it is parsed, or if they get their data in some way
 * other than loading the file.
 */
- (NSMutableData *)loadDataToBeParsed;

/*!
 * Parses the current file. Subclasses must override this method. Do not call it
 * directly.
 *
 * On entry, the file data has been loaded.  _dataStart and _current point to
 * the first byte in the data, and _dataEnd points just after the last byte.
 * Typically, subclasses will have lots of loops of the form
 * "while (_current < _dataEnd)".
 */
- (void)parseCurrentFile;


@end
