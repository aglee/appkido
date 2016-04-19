//
//  QuietLog.h
//  AppKiDo
//
//  Created by Andy Lee on 4/4/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Credit: Mark Dalrymple <http://borkware.com/quickies/single?id=261>.
 */
extern void QuietLog (NSString *format, ...);


#define QLOG_SHOULD_BE_QUIET 1
#if QLOG_SHOULD_BE_QUIET
#define QLog QuietLog
#else
#define QLog NSLog
#endif

