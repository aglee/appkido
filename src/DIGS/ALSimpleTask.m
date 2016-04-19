//
//  ALSimpleTask.m
//  ALUtilities
//
//	Copyright (c) 2011 Andy Lee
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//	and associated documentation files (the "Software"), to deal in the Software without restriction,
//	including without limitation the rights to use, copy, modify, merge, publish, distribute,
//	sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//	furnished to do so. Attribution is not required for either source or binary forms of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
//	BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ALSimpleTask.h"

@implementation ALSimpleTask

- (id)initWithCommandPath:(NSString *)commandPath arguments:(NSArray *)args
{
	self = [super init];
	if (self)
	{
		_commandPath = [commandPath copy];
		_commandArguments = [args copy];
		_taskOutputData = [[NSMutableData alloc] init];
	}

	return self;
}

- (void)dealloc
{
	// We call this in dealloc because besides ensuring the task is stopped, it
	// disconnects weak references.
	[self _stopTask];
    

}

- (BOOL)runTask
{
	// Only allow ourselves to run the command once.
	if (_task)
	{
		NSLog(@"%@ should only be called once per instance of %@.",
			  NSStringFromSelector(_cmd), [self className]);
		abort();
	}

	// Set up the NSTask instance that will run the command.
	_task = [[NSTask alloc] init];

	[_task setStandardOutput:[NSPipe pipe]];
	[_task setStandardError:[_task standardOutput]];
	[_task setLaunchPath:_commandPath];
	[_task setArguments:_commandArguments];

	// Register to be notified when there is data waiting in the task's file
	// handle (the pipe to which we connected stdout and stderr above). We do
	// this because if the file handle gets filled up, the task will block
	// waiting to send data and we'll never get anywhere. So we have to keep
	// reading data from the file handle as we go.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_taskDidProduceOutput:)
												 name:NSFileHandleReadCompletionNotification
											   object:[[_task standardOutput] fileHandleForReading]];

	// Tell the file handle to read in the background asynchronously. The file
	// handle will send a NSFileHandleReadCompletionNotification (which we just
	// registered to observe) when it has data available.
	[[[_task standardOutput] fileHandleForReading] readInBackgroundAndNotify];

	// Try to launch the task.
	@try
	{
		[_task launch];
		_taskDidLaunch = YES;
        
		[_task waitUntilExit];
		_taskExitStatus = [_task terminationStatus];
	}
	@catch (NSException *exception)
	{
		if ([[exception name] isEqualToString:NSInvalidArgumentException])
		{
			[_taskOutputData setData:[[exception reason] dataUsingEncoding:NSUTF8StringEncoding]];
			return NO;
		}
		else
		{
			@throw exception;
		}
	}

	return YES;
}

- (NSData *)outputData
{
	return [_taskOutputData copy];
}

- (NSString *)outputString
{
	return [[NSString alloc] initWithData:_taskOutputData
                                  encoding:NSUTF8StringEncoding];
}

- (int)exitStatus
{
    return _taskExitStatus;
}

#pragma mark -
#pragma mark Private methods

// Called when data is available from the task's file handle.
// [aNotification object] is the file handle.
- (void)_taskDidProduceOutput:(NSNotification *)aNotification
{
	NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];

	if ([data length])
	{
		// Collect the task's output.
		[_taskOutputData appendData:data];

		// Schedule the file handle to read more data.
		[[aNotification object] readInBackgroundAndNotify];
	}
	else
	{
		// There is no more data to get from the file handle, so shut down.
		[self _stopTask];
	}
}

- (void)_stopTask
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSFileHandleReadCompletionNotification
												  object:[[_task standardOutput] fileHandleForReading]];
	if (_taskDidLaunch)
	{
		[_task terminate];

		// Drain any remaining output data the task generates.
		NSData *data;
		while ((data = [[[_task standardOutput] fileHandleForReading] availableData]) && [data length])
		{
			[_taskOutputData appendData:data];
		}
	}
}

@end
