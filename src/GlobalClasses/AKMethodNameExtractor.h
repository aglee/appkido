//
//  AKMethodNameExtractor.h
//  AppKiDo
//
//  Created by Andy Lee on 7/14/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Tries to tell whether a string contains an Objective-C method name. Expects two
 * common cases: either the input string is a message-send or a method declaration.
 *
 * Here's the general approach. Look for top-level "elements" in the input string.
 * Discard anything in parentheses or brackets and examine what remains. If the elements
 * look like the keywords in a keyword message ("flyToX:", "y:", "z:"), glue them together
 * and return the result ("flyToX:y:z:"). Otherwise, if the last top-level element looks
 * like a unary method name (basically a C identifier), return that.
 *
 * See comments in the .m for implementation details.
 */
@interface AKMethodNameExtractor : NSObject
{
@private
    char *_buffer;  // Points to a buffer containing the zero-terminated UTF8 string we want to parse.
    char *_current;  // Points to the character within _buffer that we're currently parsing.
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithString:(NSString *)string;

#pragma mark -
#pragma mark Parsing

+ (NSString *)extractMethodNameFromString:(NSString *)string;
- (NSString *)extractMethodName;

@end
