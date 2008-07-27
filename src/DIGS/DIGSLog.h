/*
 * DIGSLog.h
 *
 * Created by Andy Lee on Wed Jul 10 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * @header      DIGSLog
 * @discussion  Wrappers around NSLog that allow setting of log verbosity
 *              levels.
 */

/*!
 * @enum        Log verbosity levels
 * @abstract    Values that can be passed to DIGSSetVerbosityLevel().
 * @discussion  Anything lower than DIGS_VERBOSITY_NONE works the same
 *              as DIGS_VERBOSITY_NONE, and anything higher than
 *              DIGS_VERBOSITY_ALL works the same as DIGS_VERBOSITY_ALL.
 *
 * @constant    DIGS_VERBOSITY_NONE
 *                  Use DIGS_VERBOSITY_NONE to suppress all log output.
 * @constant    DIGS_VERBOSITY_ERROR
 *                  Use DIGS_VERBOSITY_ERROR to log anomalies without
 *                  workarounds.
 * @constant    DIGS_VERBOSITY_WARNING
 *                  Use DIGS_VERBOSITY_WARNING to log anomalies with
 *                  workarounds.
 * @constant    DIGS_VERBOSITY_INFO
 *                  Use DIGS_VERBOSITY_INFO to log normal information
 *                  about the state of the program.  This is the default
 *                  verbosity level.  
 * @constant    DIGS_VERBOSITY_DEBUG
 *                  Use DIGS_VERBOSITY_DEBUG to log information that is
 *                  only needed for debugging and should not be logged
 *                  by a deployed version of the app.
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
    DIGS_VERBOSITY_ALL = 99,
};

/*!
 * @const       DIGSLogVerbosityUserDefault
 * @discussion  For use by NSUserDefaults.  Value is @"DIGSVerbosity".
 */
extern const NSString *DIGSLogVerbosityUserDefault;

/*!
 * @function    DIGSGetVerbosityLevel
 * @discussion  Returns the verbosity level used by the various
 *              DIGSLogXXX() functions.
 */
extern int DIGSGetVerbosityLevel();

/*!
 * @function    DIGSSetVerbosityLevel
 * @discussion  Sets the verbosity level used by the various DIGSLogXXX()
 *              functions.
 */
extern void DIGSSetVerbosityLevel(int level);

/*!
 * @function    DIGSLogError
 * @discussion  Logs output if verbosity level >= DIGS_VERBOSITY_ERROR.
 */
#define DIGSLogError(format, ...)\
do {\
    if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_ERROR)\
    {\
        NSLog(\
            [@"[_ERROR_] " stringByAppendingString:(format)],\
            ## __VA_ARGS__);\
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
        NSLog(\
            [@"[_WARNING_] " stringByAppendingString:(format)],\
            ## __VA_ARGS__);\
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
        NSLog(\
            [@"[_INFO_] " stringByAppendingString:(format)],\
            ## __VA_ARGS__);\
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
        NSLog(\
            [@"[_DEBUG_] " stringByAppendingString:(format)],\
            ## __VA_ARGS__);\
    }\
} while (0)

/*!
 * @function    DIGSLogMissingOverride
 * @discussion  Stick this in implementations of abstract methods.
 */
#define DIGSLogMissingOverride()\
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
 * @function    DIGSLogEnteringMethod
 * @discussion  Stick this at the beginning of a method to log the fact
 *              that it is being entered.
 */
#define DIGSLogEnteringMethod()\
do {\
    {\
        if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_DEBUG)\
            DIGSLogDebug(\
                @"%@ -- entering %@",\
                [self class],\
                NSStringFromSelector(_cmd));\
    }\
} while (0)

/*!
 * @function    DIGSLogExitingMethodPrematurely
 * @discussion  Call this to log the fact that you are about to return
 *              from a method prematurely due to an error condition.
 */
#define DIGSLogExitingMethodPrematurely(msgString)\
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
 * @function    DIGSLogExitingMethod
 * @discussion  Stick this at the end of a method to log the fact that it
 *              is being exited.
 */
#define DIGSLogExitingMethod()\
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
 * @function    DIGSLogNondesignatedInitializer
 * @discussion  Call this in the implementation of an initializer that
 *              should never be called because it is not the designated
 *              initializer.
 */
#define DIGSLogNondesignatedInitializer()\
do {\
    {\
        if (DIGSGetVerbosityLevel() >= DIGS_VERBOSITY_ERROR)\
            DIGSLogError(\
                @"%@ -- '%@' is not the designated initializer",\
                [self class],\
                NSStringFromSelector(_cmd));\
    }\
} while (0)

/*!
 * @function    DIGSPrintf
 * @discussion  Like printf(), but allows %@ in the format string.
 */
extern int DIGSPrintf(NSString *format, ...);

/*!
 * @function    DIGSPrintln
 * @discussion  Like DIGSPrintf(), but adds a newline at the end of the format string.
 */
extern int DIGSPrintln(NSString *format, ...);
