/* $Id$ */

/*
 *  Copyright (c) 2006-2009 Axel Andersson
 *  All rights reserved.
 * 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import <WiredAppKit/WIExceptionHandler.h>

@implementation WIExceptionHandler

+ (id)sharedExceptionHandler {
	static WIExceptionHandler	*sharedExceptionHandler;
	
	if(!sharedExceptionHandler)
		sharedExceptionHandler = [[self alloc] init];
	
	return sharedExceptionHandler;
}



#pragma mark -

- (BOOL)exceptionHandler:(NSExceptionHandler *)exceptionHandler shouldLogException:(NSException *)exception mask:(NSUInteger)mask {
	NSArray				*stacks;
	NSMutableString		*backtrace;
	NSString			*trace;
	FILE				*fp;
	char				buffer[BUFSIZ];
	NSUInteger			i = 0;
	BOOL				handled = NO;

	trace = [[exception userInfo] objectForKey:NSStackTraceKey];
	
	if(trace) {
		stacks	= [trace componentsSeparatedByString:@"  "];
		fp		= popen([[NSSWF:@"/usr/bin/atosx -p %d %@", getpid(), trace] UTF8String], "r");
		
		if(fp) {
			backtrace = [NSMutableString string];
			
			while(fgets(buffer, (int) sizeof(buffer), fp) != NULL) {
				[backtrace appendFormat:@"%d%*s%@ in %s",
					i,
					i < 10 ? 3 : i < 100 ? 2 : i < 1000 ? 3 : 1,
					" ",
					[stacks objectAtIndex:i],
					buffer];
				
				i++;
			}
			
			if([backtrace length] > 0) {
				if([delegate respondsToSelector:@selector(exceptionHandler:receivedExceptionWithBacktrace:)]) {
					[delegate exceptionHandler:self receivedExceptionWithBacktrace:backtrace];
					
					handled = YES;
				}

				NSLog(@"%@", backtrace);
			}
			
			pclose(fp);
		} else {
			NSLog(@"*** %@: popen() failed", [self class]);
		}
	} else {
		NSLog(@"*** %@: Exception has no backtrace", [self class]);
	}
	
	if(i == 0)
		NSLog(@"*** %@: Unable to log backtrace \"%@\"", [self class], trace);
	
	if(!handled) {
		if([delegate respondsToSelector:@selector(exceptionHandler:receivedException:)])
			[delegate exceptionHandler:self receivedException:exception];
	}
	
	return NO;
}



#pragma mark

- (void)setDelegate:(id)newDelegate {
	delegate = newDelegate;
}



- (id)delegate {
	return delegate;
}



#pragma mark -

- (void)enable {
	[self enableWithMask:(NSLogUncaughtExceptionMask |
						  NSLogUncaughtSystemExceptionMask |
						  NSLogUncaughtRuntimeErrorMask |
						  NSLogTopLevelExceptionMask |
						  NSLogOtherExceptionMask)];
}



- (void)enableWithMask:(NSUInteger)mask {
	[[NSExceptionHandler defaultExceptionHandler] setDelegate:self];
	[[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask:mask];
}

@end
