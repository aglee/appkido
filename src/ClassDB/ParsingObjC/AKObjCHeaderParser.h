/*
 * AKObjCHeaderParser.h
 *
 * Created by Andy Lee on Fri Jun 28 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKParser.h"

/*!
 * Parses Objective-C header files.
 *
 * Looks for @interface and @protocol declarations and the method declarations
 * that go with them. Creates and/or modifies database nodes in the database.
 *
 * Parsing is simplistic and assumes well-formed Objective-C. Ignores ivars, C
 * functions, and preprocessor directives.
 *
 * There is a kludge to get around the #ifdef WIN32 that appears in many
 * headers, causing things to seem to be declared twice, once in each branch of
 * the #ifdef.
 */
@interface AKObjCHeaderParser : AKParser
@end
