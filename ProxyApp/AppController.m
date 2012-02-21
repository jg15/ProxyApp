//
//  AppController.m
//  ProxyApp
//
//  Created by Joshua Girard on 1/29/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "AppController.h"

@implementation AppController
@synthesize prefWindow, prefController;

-(IBAction)showPreferences:(id)sender{
	if(!self.prefController){
        self.prefController = [[PrefController alloc] init];
    }
	ToFill=[self.prefController window].delegate;
	[ToFill fillFields];
	[NSApp activateIgnoringOtherApps:YES];
	[[self.prefController window] center];
	[[self.prefController window] makeKeyAndOrderFront: self];
    [self.prefController showWindow:self];
	[[NSApplication sharedApplication] arrangeInFront:nil];
}

- (void)dealloc {
	[ToFill release];
	[img release];
	[options release];
    [super dealloc];
}

- (IBAction)about:(id)sender
{	
    img = [NSImage imageNamed: @"Picture 1"];
    options = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"Version",@"Proxy App", @"ApplicationName",img,@"ApplicationIcon",@"Copyright 2012, Joshua Girard", @"Copyright",@"Proxy App", @"ApplicationVersion",nil];
	
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
	[[NSApplication sharedApplication] arrangeInFront:nil];
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

-(id)fillFields{
	
	standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults){
		server = [standardUserDefaults objectForKey:@"server"];
		username = [standardUserDefaults objectForKey:@"username"];
		password = [standardUserDefaults objectForKey:@"password"];
		port = [standardUserDefaults objectForKey:@"port"];
		strictHostKey = [standardUserDefaults objectForKey:@"strictHostKey"];
		autoProxyResume = [standardUserDefaults objectForKey:@"autoProxyResume"];
		growl = [standardUserDefaults objectForKey:@"growl"];
		if([strictHostKey isEqualToString:@"On"]){tempValSHK=1;}else{tempValSHK=0;}
		if([autoProxyResume isEqualToString:@"On"]){tempValAPR=1;}else{tempValAPR=0;}
		if([growl isEqualToString:@"On"]){tempGrowl=1;}else{tempGrowl=0;}

		[serverField setStringValue:server];
		[usernameField setStringValue:username];
		[passwordField setStringValue:password];
		[portField setStringValue:port];
		[strictHostKeyCheckingToggle setIntValue:tempValSHK];
		[autoProxyResumeToggle setIntValue:tempValAPR];
		[growlToggle setIntValue:tempGrowl];
		
		return self;
	}
	return nil;
}
@end
