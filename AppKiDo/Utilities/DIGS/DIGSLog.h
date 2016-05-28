/*
 * DIGSLog.h
 *
 * Created by Andy Lee on Wed Jul 10 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "QuietLog.h"

/*!
 * @header      DIGSLog
 * @discussion  Wrappers around NSLog.  "DIGS" stands for "digital spokes".  I
 *              own the domain digitalspokes.com but never ended up using it.
 */

/*!
 * @enum        DIGSLog verbosity levels
 * @abstract    Values that can be passed to DIGSSetVerbosityLevel().
 * @discussion  Anything lower than DIGS_VERBOSITY_NONE works the same as
 *              DIGS_VERBOSITY_NONE. Anything higher than DIGS_VERBOSITY_ALL
 *              works the same as DIGS_VERBOSITY_ALL.
 *
 * @constant	DIGS_VERBOSITY_NONE
 *                  Use DIGS_VERBOSITY_NONE to suppress all log output.
 * @constant    DIGS_VERBOSITY_ERROR
 *                  Use DIGS_VERBOSITY_ERROR to log anomalies without workarounds.
 * @constant    DIGS_VERBOSITY_WARNING
 *					Use DIGS_VERBOSITY_WARNING to log anomalies with workarounds.
 * @constant	DIGS_VERBOSITY_INFO
 *                  Use DIGS_VERBOSITY_INFO to log normal information about the
 *					state of the program.  This is the default verbosity level.
 * @constant    DIGS_VERBOSITY_DEBUG
 *                  Use DIGS_VERBOSITY_DEBUG to log information that is only
 *                  needed for debugging and should not be logged by a deployed
 *                  version of the app.
 * @constant    DIGS_VERBOSITY_DEBUG2
 *                  Like DIGS_VERBOSITY_DEBUG, but more verbose.
 * @constant    DIGS_VERBOSITY_DEBUG3
 *                  Like DIGS_VERBOSITY_DEBUG2, but more verbose.
 * @constant    DIGS_VERBOSITY_ALL
 *                  Use DIGS_VERBOSITY_ALL to turn on all logging.
 */
enum
{
	DIGS_VERBOSITY_NONE = 0,
	DIGS_VERBOSITY_ERROR = 10,
	DIGS_VERBOSITY_WARNING = 20,
	DIGS_VERBOSITY_INFO = 30,
	DIGS_VERBOSITY_DEBUG = 40,
	DIGS_VERBOSITY_DEBUG2 = 50,
	DIGS_VERBOSITY_DEBUG3 = 60,
	DIGS_VERBOSITY_ALL = 99,
};

/*!
 * @const       DIGSLogVerbosityUserDefault
 * @discussion  For use by NSUserDefaults.  Value is @"DIGSVerbosity".
 */
#define DIGSLogVerbosityUserDefault @"DIGSLogVerbosityUserDefault"

/*!
 * @function    DIGSGetVerbosityLevel
 * @discussion  Returns the DIGSLog verbosity level.
 */
extern NSInteger DIGSGetVerbosityLevel();

/*!
 * @function    DIGSSetVerbosityLevel
 * @discussion  Sets the verbosity level used by the various DIGSLogXXX()
 *			    functions.
 */
extern void DIGSSetVerbosityLevel(NSInteger level);

/*!
 * @function    DIGSLogError
 * @discussion  Logs output if verbosity level >= DIGS_VERBOSITY_ERROR.
 */
#define DIGSLogError(format, ...)\
do {\
	if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_ERROR)\
	{\
		NSLog(@"[_ERROR_] " format, ## __VA_ARGS__);\
	}\
} while (0)

/*!
 * @function    DIGSLogWarning
 * @discussion  Logs output if verbosity level >= DIGS_VERBOSITY_WARNING.
 */
#define DIGSLogWarning(format, ...)\
do {\
	if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_WARNING)\
	{\
		NSLog(@"[_WARNING_] " format, ## __VA_ARGS__);\
	}\
} while (0)

/*!
 * @function    DIGSLogInfo
 * @discussion  Logs output if verbosity level >= DIGS_VERBOSITY_INFO.
 */
#define DIGSLogInfo(format, ...)\
do {\
	if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_INFO)\
	{\
		NSLog(@"[_INFO_] " format, ## __VA_ARGS__);\
	}\
} while(0)

/*!
 * @function    DIGSLogDebug
 * @discussion  Logs output if verbosity level >= DIGS_VERBOSITY_DEBUG.
 */
#define DIGSLogDebug(format, ...)\
do {\
	if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_DEBUG)\
	{\
		NSLog(@"[_DEBUG_] " format, ## __VA_ARGS__);\
	}\
} while (0)

/*!
 * @function    DIGSLogDebug2
 * @discussion  Logs output if verbosity level >= DIGS_VERBOSITY_DEBUG2.
 */
#define DIGSLogDebug2(format, ...)\
do {\
	if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_DEBUG2)\
	{\
		NSLog(@"[_DEBUG2_] " format, ## __VA_ARGS__);\
	}\
} while (0)

/*!
 * @function    DIGSLogDebug3
 * @discussion  Logs output if verbosity level >= DIGS_VERBOSITY_DEBUG3.
 */
#define DIGSLogDebug3(format, ...)\
do {\
	if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_DEBUG3)\
	{\
		NSLog(@"[_DEBUG3_] " format, ## __VA_ARGS__);\
	}\
} while (0)

/*!
 * @function    DIGSLogError_MissingOverride
 * @discussion  Stick this in implementations of abstract methods.
 */
#define DIGSLogError_MissingOverride()\
do {\
	{\
		if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_ERROR)\
			DIGSLogError(\
				@"%@ must override %@",\
				[self class],\
				NSStringFromSelector(_cmd));\
	}\
} while (0)

/*!
 * @function    DIGSLogDebug_EnteringMethod
 * @discussion  Stick this at the beginning of a method to log the fact that it
 *              is being entered.
 */
#define DIGSLogDebug_EnteringMethod()\
do {\
	{\
		if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_DEBUG)\
			DIGSLogDebug(\
				@"%@ -- entering method %@",\
				[self class],\
				NSStringFromSelector(_cmd));\
	}\
} while (0)

/*!
 * @function    DIGSLogError_ExitingMethodPrematurely
 * @discussion  Call this to log the fact that you are about to return
 *              from a method prematurely due to an error condition.
 */
#define DIGSLogError_ExitingMethodPrematurely(msgString)\
do {\
	{\
		if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_ERROR)\
			DIGSLogError(\
				@"%@ -- exiting %@ early -- %@",\
				[self class],\
				NSStringFromSelector(_cmd),\
				(msgString));\
	}\
} while (0)

/*!
 * @function    DIGSLogDebug_ExitingMethod
 * @discussion  Stick this at the end of a method to log the fact that it
 *              is being exited.
 */
#define DIGSLogDebug_ExitingMethod()\
do {\
	{\
		if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_DEBUG)\
			DIGSLogDebug(\
				@"%@ -- exiting %@",\
				[self class],\
				NSStringFromSelector(_cmd));\
	}\
} while (0)

/*!
 * @function    DIGSLogError_NondesignatedInitializer
 * @discussion  Call this in the implementation of an initializer that should
 *              never be called because it is not the designated initializer.
 */
#define DIGSLogError_NondesignatedInitializer()\
do {\
	{\
		if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_ERROR)\
			DIGSLogError(\
				@"%@ -- '%@' is not the designated initializer",\
				[self class],\
				NSStringFromSelector(_cmd));\
	}\
} while (0)

