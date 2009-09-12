/* $Id$ */

/*
 *  Copyright (c) 2009 Axel Andersson
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

#import <WiredAppKit/NSAttributedString-WIAppKit.h>
#import <WiredAppKit/NSFont-WIAppKit.h>
#import <WiredAppKit/NSTextView-WIAppKit.h>
#import <WiredAppKit/WICrashReportsController.h>
#import <WiredAppKit/WITableView.h>

@interface WICrashReport : WIObject {
@public
	NSString					*_name;
	NSString					*_path;
	NSDate						*_date;
}

- (NSComparisonResult)compareDate:(WICrashReport *)other;

@end


@implementation WICrashReport

- (void)dealloc {
	[_name release];
	[_path release];
	[_date release];
	
	[super dealloc];
}



- (NSComparisonResult)compareDate:(WICrashReport *)other {
	return [self->_date compare:other->_date];
}

@end



@interface WICrashReportsController(Private)

- (void)_reloadCrashReports;
- (NSArray *)_crashReportsInDirectoryAtPath:(NSString *)path;

@end


@implementation WICrashReportsController(Private)

- (void)_reloadCrashReports {
	NSEnumerator		*enumerator;
	NSString			*path, *crashReporterPath;
	
	[_crashReports removeAllObjects];
	
	enumerator = [NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSAllDomainsMask, YES) objectEnumerator];
	
	while((path = [enumerator nextObject])) {
		crashReporterPath = [[path stringByAppendingPathComponent:@"Logs"]
			stringByAppendingPathComponent:@"CrashReporter"];
		
		if([[NSFileManager defaultManager] directoryExistsAtPath:crashReporterPath])
			[_crashReports addObjectsFromArray:[self _crashReportsInDirectoryAtPath:crashReporterPath]];
	}
	
	[_crashReports sortUsingSelector:@selector(compareDate:)];
	[_crashReports reverse];
}



- (NSArray *)_crashReportsInDirectoryAtPath:(NSString *)path {
	NSMutableArray		*crashReports;
	NSEnumerator		*enumerator;
	NSArray				*matches;
	NSString			*file, *crashReportPath;
	WICrashReport		*crashReport;
	
	crashReports	= [NSMutableArray array];
	enumerator		= [[[NSFileManager defaultManager] directoryContentsAtPath:path] objectEnumerator];
	
	while((file = [enumerator nextObject])) {
		crashReportPath = [path stringByAppendingPathComponent:file];
		
		if([[crashReportPath pathExtension] isEqualToString:@"crash"]) {
			matches = [file captureComponentsMatchedByRegex:[NSSWF:@"(%@)_(\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})(\\d{2})(\\d{2})",
				_applicationName]];
			
			if([matches count] == 8) {
				crashReport = [[WICrashReport alloc] init];
				crashReport->_name = [file retain];
				crashReport->_path = [crashReportPath retain];
				crashReport->_date = [[[NSCalendar currentCalendar] dateFromComponents:
					[NSDateComponents dateComponentsWithYear:[[matches objectAtIndex:2] unsignedIntegerValue]
													   month:[[matches objectAtIndex:3] unsignedIntegerValue]
														 day:[[matches objectAtIndex:4] unsignedIntegerValue]
														hour:[[matches objectAtIndex:5] unsignedIntegerValue]
													  minute:[[matches objectAtIndex:6] unsignedIntegerValue]
													  second:[[matches objectAtIndex:7] unsignedIntegerValue]]] retain];
				[crashReports addObject:crashReport];
				[crashReport release];
			}
		}
	}
	
	return crashReports;
}

@end



@implementation WICrashReportsController

+ (WICrashReportsController *)crashReportsController {
	static WICrashReportsController		*controller;
	
	if(!controller)
		controller = [[self alloc] init];
	
	return controller;
}



#pragma mark -

- (id)init {
	NSString		*path;
	
	_crashReports		= [[NSMutableArray alloc] init];

	_readCrashReports	= [[NSMutableSet alloc] init];
	[_readCrashReports addObjectsFromArray:
		[[NSUserDefaults standardUserDefaults] objectForKey:@"_WICrashReportsController_readCrashReports"]];
	
	_sentCrashReports	= [[NSMutableSet alloc] init];
	[_sentCrashReports addObjectsFromArray:
		[[NSUserDefaults standardUserDefaults] objectForKey:@"_WICrashReportsController_sentCrashReports"]];
	
	_dateFormatter		= [[WIDateFormatter alloc] init];
	[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	path = [[NSBundle bundleWithIdentifier:WIAppKitBundleIdentifier] pathForResource:@"CrashReports" ofType:@"nib"];
	
	self = [self initWithWindowNibPath:path owner:self];
	
	[self window];
	
	return self;
}



- (void)dealloc {
	[_applicationName release];
	[_crashReports release];
	[_dateFormatter release];
	[_readCrashReports release];
	[_sentCrashReports release];
	
	[super dealloc];
}



#pragma mark -

- (void)windowDidLoad {
	[_tableView setHighlightedTableColumn:_dateTableColumn sortOrder:WISortDescending];
}



- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset {
	return proposedMin + 50.0;
}



- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset {
	return proposedMax - 50.0;
}



- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
	NSSize		size, bottomSize, topSize;
	
	size				= [splitView frame].size;
	topSize				= [_tableScrollView frame].size;
	topSize.width		= size.width;
	bottomSize.width	= size.width;
	bottomSize.height	= size.height - [splitView dividerThickness] - topSize.height;
	
	[_tableScrollView setFrameSize:topSize];
	[_textScrollView setFrameSize:bottomSize];
	
	[splitView adjustSubviews];
}



#pragma mark -

- (void)setApplicationName:(NSString *)applicationName {
	[applicationName retain];
	[_applicationName release];
	
	_applicationName = applicationName;
	
	[self _reloadCrashReports];
	[_tableView reloadData];
}



- (NSString *)applicationName {
	return _applicationName;
}



#pragma mark -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [_crashReports count];
}



- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row {
	WICrashReport		*crashReport;
	
	crashReport = [_crashReports objectAtIndex:row];
	
	if(column == _nameTableColumn)
		return crashReport->_name;
	else if(column == _dateTableColumn)
		return [_dateFormatter stringFromDate:crashReport->_date];
	
	return NULL;
}



- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	WICrashReport		*crashReport;

	crashReport = [_crashReports objectAtIndex:row];
	
	if([_readCrashReports containsObject:crashReport->_name])
		[cell setFont:[[cell font] fontByAddingTrait:NSUnboldFontMask]];
	else
		[cell setFont:[[cell font] fontByAddingTrait:NSBoldFontMask]];
}



- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	NSDictionary		*attributes;
	NSString			*string;
	WICrashReport		*crashReport;
	NSInteger			row;
	
	row = [_tableView selectedRow];
	
	if(row >= 0) {
		crashReport		= [_crashReports objectAtIndex:row];
		string			= [NSString stringWithContentsOfFile:crashReport->_path encoding:NSUTF8StringEncoding error:NULL];
		
		if(string) {
			attributes	= [NSDictionary dictionaryWithObject:[NSFont userFixedPitchFontOfSize:11.0] forKey:NSFontAttributeName];
			
			[_textView setAttributedString:
				[NSAttributedString attributedStringWithString:string attributes:attributes]];
		}
		
		[_readCrashReports addObject:crashReport->_name];
		
		[[NSUserDefaults standardUserDefaults] setObject:[_readCrashReports allObjects]
												  forKey:@"_WICrashReportsController_readCrashReports"];
	} else {
		[_textView setString:@""];
	}
}

@end
