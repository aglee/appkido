/*
 * AKCocoaFramework.m
 *
 * Created by Andy Lee on Tue May 10 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKCocoaFramework.h"

#import <DIGSLog.h>

#import "AKFileUtils.h"
#import "AKFrameworkInfo.h"
#import "AKDatabase.h"
#import "AKObjCHeaderParser.h"
#import "AKCocoaBehaviorDocParser.h"
#import "AKCocoaFunctionsDocParser.h"
#import "AKCocoaGlobalsDocParser.h"


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@interface AKCocoaFramework (Private)

- (NSString *)_classesDocDir;
- (NSString *)_protocolsDocDir;
- (NSString *)_functionsDocDir;
- (NSString *)_constantsDocDir;
- (NSString *)_dataTypesDocDir;

- (void)_parseBehaviorDocsInDirectory:(NSString *)dirPath
    forDatabase:(AKDatabase *)db;
- (void)_parseFunctionsDocsForDatabase:(AKDatabase *)db;
- (void)_parseGlobalsDocsForDatabase:(AKDatabase *)db;

@end


@implementation AKCocoaFramework

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)frameworkWithName:(NSString *)fwName
{
    // Figure out what descendant class of AKFramework we need
    // to instantiate.
    NSString *fwClassName =
        [AKFrameworkInfo frameworkClassForFrameworkNamed:fwName];
    Class fwClass =
        fwClassName
        ? NSClassFromString(fwClassName)
        : [AKCocoaFramework class];

    if (!fwClass)
    {
        DIGSLogError(
            @"(framework %@) there is no class named %@",
            fwName, fwClassName);
        return nil;
    }
    else if (![fwClass isSubclassOfClass:[AKCocoaFramework class]])
    {
        DIGSLogError(
            @"(framework %@) %@ is not a descendant class of %@",
            fwName, [fwClass className], [AKCocoaFramework className]);
        return nil;
    }
    else
    {
        return [[[fwClass alloc] initWithName:fwName] autorelease];
    }
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithName:(NSString *)fwName
{
    if ((self = [super initWithName:fwName]))
    {
        _headerDir = [[AKFrameworkInfo headerDirForFrameworkNamed:fwName] retain];
        _mainDocDir = [[AKFrameworkInfo docDirForFrameworkNamed:fwName] retain];
    }

    return self;
}

- (void)dealloc
{
    [_headerDir release];
    [_mainDocDir release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)headerDir
{
    return _headerDir;
}

- (NSString *)mainDocDir
{
    return _mainDocDir;
}

//-------------------------------------------------------------------------
// AKFramework methods
//-------------------------------------------------------------------------

- (void)populateDatabase:(AKDatabase *)db
{
    // Parse header files before HTML files, so that later when we parse a
    // "Deprecated Methods" HTML file we can distinguish between instance
    // methods, class methods, and delegate methods by querying the database.
    // We also use header info to distinguish formal protocols from informal
    // ones -- informal ones do not have an associated header.
    // ([agl] Is this a reliable test for informal protocols?)
    NSString *dirName = [self headerDir];
    AKObjCHeaderParser *headerParser =  // no autorelease
        [[AKObjCHeaderParser alloc]
            initWithDatabase:db frameworkName:_frameworkName];
    
    DIGSLogDebug(@"parsing headers in %@", dirName);
    [headerParser processDirectory:dirName recursively:YES];
    
    [headerParser release];  // release here

    // Parse HTML files.
    NSString *classesDocDir = [self _classesDocDir];
    [self
        _parseBehaviorDocsInDirectory:classesDocDir
        forDatabase:db];

    NSString *protocolsDocDir = [self _protocolsDocDir];
    if (![protocolsDocDir isEqualToString:classesDocDir])
    {
        [self _parseBehaviorDocsInDirectory:protocolsDocDir
            forDatabase:db];
    }

    [self _parseFunctionsDocsForDatabase:db];
    [self _parseGlobalsDocsForDatabase:db];
}

@end


//-------------------------------------------------------------------------
// Protected methods
//-------------------------------------------------------------------------

@implementation AKCocoaFramework (Private)

// We have to glance at the filesystem to see what the paths of our
// various subdirectories are.  For example, the "Functions" and
// "TypesAndConstants" subdirectories are optional -- not all frameworks
// have them.
//
// Note that although we check for both "Classes" and "classes", on
// an HFS+ filesystem, they're actually treated as equal.  Checking for
// both would only matter if this code could be running on a
// case-sensitive filesystem.  This is annoying because we could be
// using a path .../Classes when it's really .../classes -- but it
// *shouldn't* be noticeable to the user.
- (NSString *)_classesDocDir
{
/*
    return
        [AKFileUtils
            subdirectoryOf:[self mainDocDir]
            withName:@"Classes"
            orName:@"classes"];
*/
    return [self mainDocDir];
}

- (NSString *)_protocolsDocDir
{
/*
    return
        [AKFileUtils
            subdirectoryOf:[self mainDocDir]
            withName:@"Protocols"
            orName:@"protocols"];
*/
    return [self mainDocDir];
}

- (NSString *)_functionsDocDir
{
	NSString *miscPath =
		[[self mainDocDir] stringByAppendingPathComponent:@"Miscellaneous"];
    return
        [AKFileUtils
            subdirectoryOf:miscPath
            withNameEndingWith:@"Functions"];
}

- (NSString *)_constantsDocDir
{
	NSString *miscPath =
		[[self mainDocDir] stringByAppendingPathComponent:@"Miscellaneous"];
    return
        [AKFileUtils
            subdirectoryOf:miscPath
            withNameEndingWith:@"Constants"];
}

- (NSString *)_dataTypesDocDir
{
	NSString *miscPath =
		[[self mainDocDir] stringByAppendingPathComponent:@"Miscellaneous"];
    return
        [AKFileUtils
            subdirectoryOf:miscPath
            withNameEndingWith:@"DataTypes"];
}

- (void)_parseBehaviorDocsInDirectory:(NSString *)dirPath
    forDatabase:(AKDatabase *)db
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath])
    {
        AKCocoaBehaviorDocParser *parser =  // no autorelease
            [[AKCocoaBehaviorDocParser alloc]
                initWithDatabase:db frameworkName:_frameworkName];

        DIGSLogDebug(@"parsing behavior docs in %@", dirPath);
        [parser processDirectory:dirPath recursively:YES];

        [parser release];  // release here
    }
}

- (void)_parseFunctionsDocsForDatabase:(AKDatabase *)db
{
    DIGSLogDebug(@"parsing functions for %@", [self frameworkName]);

    AKDocParser *parser =  // no autorelease
        [[AKCocoaFunctionsDocParser alloc]
            initWithDatabase:db frameworkName:_frameworkName];

    [parser
        processDirectory:[self _functionsDocDir]
        recursively:YES];

    [parser release];  // release here
}

- (void)_parseGlobalsDocsForDatabase:(AKDatabase *)db
{
    DIGSLogDebug(
        @"parsing globals for %@", [self frameworkName]);

    AKCocoaGlobalsDocParser *parser =  // no autorelease
        [[AKCocoaGlobalsDocParser alloc]
            initWithDatabase:db frameworkName:_frameworkName];

    [parser
        processDirectory:[self _constantsDocDir]
        recursively:YES];

    [parser
        processDirectory:[self _dataTypesDocDir]
        recursively:YES];

    [parser release];  // release here
}

@end
