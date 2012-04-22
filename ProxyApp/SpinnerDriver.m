//
//  SpinnerDriver.m
//  ProxyApp
//
//  Created by Joshua Girard on 3/15/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "SpinnerDriver.h"

@implementation SpinnerDriver
@synthesize spinWindow, spinnerController;

BOOL spinShowing=NO;

-(id)start{
	if(!self.spinnerController){
        self.spinnerController = [[SpinnerController alloc] init];
	}
	if(!spinShowing){
		[[self.spinnerController window] setOpaque:NO];
		NSColor *backgroundColor = [[self.spinnerController window] backgroundColor];
		backgroundColor = [backgroundColor colorWithAlphaComponent:0.0];
		[[self.spinnerController window] setBackgroundColor:backgroundColor];
		//[[self.spinnerController window] setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.0]];
		spinWindow=[self.spinnerController window];
		spinStarter=[self.spinnerController window].delegate;
		[spinStarter ToSpin];
		//[spinner performSelector:@selector(startAnimation:) withObject:spinStarter];
		[NSApp activateIgnoringOtherApps:YES];
		//[[self.spinnerController window] center];
		[[self.spinnerController window] makeKeyAndOrderFront: self];
		[self.spinnerController showWindow:self];
		[[NSApplication sharedApplication] arrangeInFront:nil];
		[[self.spinnerController window] setLevel:NSPopUpMenuWindowLevel];
		spinShowing=YES;
		NSLog(@"%@",self);
	}else{
		return nil;
	}
	return self;
}

-(id)stop{
	if(spinShowing){
		[self.spinnerController performSelector: @selector(close)];
		spinShowing=NO;
	}else{
		return nil;
	}
	return self;
}

-(id)ToSpin{
	[spinner startAnimation:self];
	return self;
}

@end