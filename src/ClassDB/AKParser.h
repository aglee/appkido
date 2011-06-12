/*
 * AKParser.h
 *
 * Created by Andy Lee on Sat Mar 06 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSFileProcessor.h"

@class AKFramework;

// [agl] add checks for buffer overflow
#define AKTokenBufferSize 1024

/*!
 * @class       AKParser
 * @abstract    Base class for parsers used to populate the AppKiDo database.
 * @discussion  An AKParser parses files that contain API information,
 *              creates database nodes that encapsulate that information,
 *              and inserts the nodes into an AKDatabase.
 *
 *              A given instance of AKParser associates all nodes it creates
 *              with one framework, and inserts all the nodes into that
 *              framework's database.  The framework is assigned by AKParser's
 *              designated initializer.
 *
 *              Each subclass of AKParser parses a particular type of file.
 *              Subclasses must override -parseCurrentFile, and must NOT
 *              override -processCurrentFile.
 *
 *              Three protected instance variables -- _dataStart, _current,
 *              and _dataEnd -- can be used by subclasses in their
 *              -parseCurrentFile methods.  See -parseCurrentFile for
 *              details.
 */
@interface AKParser : DIGSFileProcessor
{
@protected
    AKFramework *_parserFW;

    // These protected ivars are only used during parsing.  They point to
    // various positions in the data being parsed.
    const char *_dataStart;
    const char *_current;
    const char *_dataEnd;
}


#pragma mark -
#pragma mark Class methods

+ (void)recursivelyParseDirectory:(NSString *)dirPath forFramework:(AKFramework *)aFramework;

+ (void)parseFilesInPaths:(NSArray *)docPaths
    underBaseDir:(NSString *)baseDir
    forFramework:(AKFramework *)aFramework;


#pragma mark -
#pragma mark Init/awake/dealloc

/*!
 * @method      initWithFramework:
 * @discussion  Designated initializer.
 */
- (id)initWithFramework:(AKFramework *)aFramework;


#pragma mark -
#pragma mark Parsing

/*!
 * @method      loadDataToBeParsed
 * @discussion  This method is used internally by -parseCurrentFile.  By
 *              default, it returns the contents of [self currentPath].
 *
 *              You shouldn't call this method.  Subclasses can override it
 *              if they want to modify the data before it is parsed, or if
 *              they get their data in some way other than loading the file.
 */
- (NSMutableData *)loadDataToBeParsed;

/*!
 * @method      parseCurrentFile
 * @discussion  Processes the current file.  Subclasses must override this
 *              method, and must not override -processCurrentFile, which
 *              calls this method.
 *
 *              On entry, the file data has been loaded.  _dataStart and
 *              _current point to the first byte in the data, and _dataEnd
 *              points just after the last byte.  Typically, subclasses
 *              will have lots of loops of the form "while (_current <
 *              _dataEnd)".
 */
- (void)parseCurrentFile;

@end
