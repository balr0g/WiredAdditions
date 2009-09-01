/* $Id$ */

/*
 *  Copyright (c) 2008-2009 Axel Andersson
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

// --- 10.5 stuff while building on 10.4
#ifndef NSINTEGER_DEFINED
#if __LP64__ || NS_BUILD_32_LIKE_64
typedef long					NSInteger;
typedef unsigned long			NSUInteger;
#else
typedef int						NSInteger;
typedef unsigned int			NSUInteger;
#endif

#define NSIntegerMax			LONG_MAX
#define NSIntegerMin			LONG_MIN
#define NSUIntegerMax			ULONG_MAX

#define NSINTEGER_DEFINED		1
#endif

#ifndef CGFLOAT_DEFINED
#if defined(__LP64__) && __LP64__
typedef double					CGFloat;
#define CGFLOAT_MIN				DBL_MIN
#define CGFLOAT_MAX				DBL_MAX
#define CGFLOAT_IS_DOUBLE		1
#else
typedef float					CGFloat;
#define CGFLOAT_MIN				FLT_MIN
#define CGFLOAT_MAX				FLT_MAX
#define CGFLOAT_IS_DOUBLE		0
#endif

#define CGFLOAT_DEFINED			1
#endif

#ifndef MAC_OS_X_VERSION_10_5
#define MAC_OS_X_VERSION_10_5	1050
#endif

#import <WiredFoundation/WIObject.h>

#import <WiredFoundation/WIDateFormatter.h>
#import <WiredFoundation/WIEventQueue.h>
#import <WiredFoundation/WIMacros.h>
#import <WiredFoundation/WIReadWriteLock.h>
#import <WiredFoundation/WISettings.h>
#import <WiredFoundation/WITextFilter.h>
#import <WiredFoundation/WITypes.h>
#import <WiredFoundation/WIURL.h>

#import <WiredFoundation/NSArray-WIFoundation.h>
#import <WiredFoundation/NSData-WIFoundation.h>
#import <WiredFoundation/NSDate-WIFoundation.h>
#import <WiredFoundation/NSDateComponents-WIFoundation.h>
#import <WiredFoundation/NSDictionary-WIFoundation.h>
#import <WiredFoundation/NSError-WIFoundation.h>
#import <WiredFoundation/NSFileManager-WIFoundation.h>
#import <WiredFoundation/NSInvocation-WIFoundation.h>
#import <WiredFoundation/NSLocale-WIFoundation.h>
#import <WiredFoundation/NSNetService-WIFoundation.h>
#import <WiredFoundation/NSNotificationCenter-WIFoundation.h>
#import <WiredFoundation/NSNumber-WIFoundation.h>
#import <WiredFoundation/NSObject-WIFoundation.h>
#import <WiredFoundation/NSProcessInfo-WIFoundation.h>
#import <WiredFoundation/NSScanner-WIFoundation.h>
#import <WiredFoundation/NSSet-WIFoundation.h>
#import <WiredFoundation/NSString-WIFoundation.h>
#import <WiredFoundation/NSThread-WIFoundation.h>

#import <WiredFoundation/RegexKitLite.h>
#import <WiredFoundation/RegexKitLite-WIFoundation.h>
