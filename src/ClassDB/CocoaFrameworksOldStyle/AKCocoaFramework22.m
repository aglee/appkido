/*
 * AKCocoaFramework22.m
 *
 * Created by Andy Lee on Tue May 27 2006.
 * Copyright (c) 2006 Andy Lee. All rights reserved.
 */

#import "AKCocoaFramework22.h"

#import <DIGSLog.h>

#import "AKFileUtils.h"
#import "AKDatabase.h"
#import "AKObjCHeaderParser.h"
#import "AKCocoaBehaviorDocParser.h"
#import "AKCocoaFunctionsDocParser.h"
#import "AKCocoaGlobalsDocParser.h"


@implementation AKCocoaFramework22

//-------------------------------------------------------------------------
// AKCocoaFramework protected methods
//-------------------------------------------------------------------------

- (NSString *)_functionsDocDir
{
    return
        [AKFileUtils
            subdirectoryOf:[self mainDocDir]
            withName:@"Functions"
            orName:@"functions"];
}

- (NSString *)_constantsDocDir
{
    return nil;
}

- (NSString *)_dataTypesDocDir
{
    return
        [AKFileUtils
            subdirectoryOf:[self mainDocDir]
            withName:@"TypesAndConstants"
            orName:@"typesandconstants"];
}

@end
