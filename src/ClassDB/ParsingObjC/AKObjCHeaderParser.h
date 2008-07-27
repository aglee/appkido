/*
 * AKObjCHeaderParser.h
 *
 * Created by Andy Lee on Fri Jun 28 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKParser.h"

@class AKObjCFramework;

/*!
 * @class       AKObjCHeaderParser
 * @abstract    Parses Objective-C header files.
 * @discussion  Looks for @interface and @protocol declarations, and the
 *              method declarations that go with them.  Modifies and
 *              creates AKDatabaseNodes and plugs them into the database.
 *
 *              Parsing is simplistic and assumes well-formed Objective-C
 *              syntax.  Ignores instance variables, C functions, and
 *              #imported or #included files.  Does not evaluate macros or
 *              #ifdefs.
 *
 *              There is a kludge to get around the #ifdef WIN32 that
 *              appears in many headers, causing things to seem to be
 *              declared twice, once in each branch of the #ifdef.
 */
@interface AKObjCHeaderParser : AKParser
{
}

@end
