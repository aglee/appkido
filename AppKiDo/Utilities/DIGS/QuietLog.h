//
//  QuietLog.h
//  AppKiDo
//
//  Created by Andy Lee on 4/4/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Like NSLog, but omits the info NSLog puts at the beginning of each line.
 *
 * Credit: Mark Dalrymple <http://borkware.com/quickies/single?id=261>.
 */
extern void QuietLog (NSString *format, ...);

// Either QLog and NSLog are both quiet, or they're both ver
#define QLOG_SHOULD_BE_QUIET 1
#if QLOG_SHOULD_BE_QUIET
#define QLog QuietLog
#define NSLog QuietLog
#else
#define QLog NSLog
#endif

