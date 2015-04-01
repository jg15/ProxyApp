//
//  AppController.m
//  ProxyApp
//
//  Created by Joshua Girard on 1/29/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "AppController.h"
#import "Keychain.h"

@implementation AppController
@synthesize prefWindow, prefController;

-(IBAction)showPreferences:(id)sender{
	[self openPreferences];
}

-(void)openPreferences{
	if(!self.prefController){
        self.prefController = [[PrefController alloc] init];
    }
	//[self adjustSize];
	
	//NSRect windowFrame = [[self.prefController window] frame];
	//windowFrame.size.height = 180.0f;
	//NSLog(@"%@",[tabView identifier]);
	//if([tabView identifier]==@"Program Options"){
		//[[self.prefController window] setFrame:windowFrame display:YES animate:YES];
	//}else if ([tabView identifier]==@"Server Settings") {
		
	//}
	
	
	ToFill=[self.prefController window].delegate;
	[ToFill fillFields];
	[NSApp activateIgnoringOtherApps:YES];
	[[self.prefController window] center];
	[[self.prefController window] makeKeyAndOrderFront: self];
    [self.prefController showWindow:self];
	[[NSApplication sharedApplication] arrangeInFront:nil];
	[[self.prefController window] setLevel:NSPopUpMenuWindowLevel];
}

- (void)dealloc {
	[ToFill release];
	[img release];
	[options release];
    [super dealloc];
}

- (IBAction)about:(id)sender
{
	NSLog(@"%@",[keychain getItem:@"ProxyApp"]);
    img = [NSImage imageNamed: @"Picture 1"];
    options = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"Version",@"Proxy App", @"ApplicationName",img,@"ApplicationIcon",@"Copyright 2013, Joshua Girard", @"Copyright",@"Proxy App", @"ApplicationVersion",nil];
	
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
	[[NSApplication sharedApplication] arrangeInFront:nil];
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

-(id)fillFields{
	
	//[spinner startAnimation:self];
	
	standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults){
		server = [standardUserDefaults objectForKey:@"server"];
		username = [standardUserDefaults objectForKey:@"username"];
		//password = [standardUserDefaults objectForKey:@"password"];
		password = [keychain getItem:@"ProxyApp"];
		if(password==NULL)password=@"";
		port = [standardUserDefaults objectForKey:@"port"];
		strictHostKey = [standardUserDefaults objectForKey:@"strictHostKey"];
		autoProxyResume = [standardUserDefaults objectForKey:@"autoProxyResume"];
		growl = [standardUserDefaults objectForKey:@"growl"];
		verboseGrowl = [standardUserDefaults objectForKey:@"verboseGrowl"];
		tunnelWiFi = [standardUserDefaults objectForKey:@"dontTunnelWiFi"];
		tunnelEthernet = [standardUserDefaults objectForKey:@"dontTunnelEthernet"];
		if([strictHostKey isEqualToString:@"On"]){tempValSHK=1;}else{tempValSHK=0;}
		if([autoProxyResume isEqualToString:@"On"]){tempValAPR=1;}else{tempValAPR=0;}
		if([growl isEqualToString:@"On"]){tempGrowl=1;}else{tempGrowl=0;}
		if([verboseGrowl isEqualToString:@"On"]){tempVerboseGrowl=1;}else{tempVerboseGrowl=0;}
		if([tunnelWiFi isEqualToString:@"True"]){tempTunnelWiFi=1;}else{tempTunnelWiFi=0;}
		if([tunnelEthernet isEqualToString:@"True"]){tempTunnelEthernet=1;}else{tempTunnelEthernet=0;}

		[serverField setStringValue:server];
		[usernameField setStringValue:username];
		[passwordField setStringValue:password];
		[portField setStringValue:port];
		[strictHostKeyCheckingToggle setIntValue:tempValSHK];
		[autoProxyResumeToggle setIntValue:tempValAPR];
		[growlToggle setIntValue:tempGrowl];
		[verboseGrowlToggle setIntValue:tempVerboseGrowl];
		[tunnelWiFiToggle setIntValue:tempTunnelWiFi];
		[tunnelEthernetToggle setIntValue:tempTunnelEthernet];
		
		if(tempGrowl==1){[verboseGrowlToggle setEnabled:YES];}else{[verboseGrowlToggle setEnabled:NO];}
		
		return self;
	}
	return nil;
}

-(void)adjustSize{
	NSRect windowFrame = [[self.prefController window] frame];
	windowFrame.size.height = 180.0f;
	//if([tabView identifier]==@"Program Options"){
		[[self.prefController window] setFrame:windowFrame display:YES animate:YES];
	//}else if ([tabView identifier]==@"Server Settings") {
		
	//}
}

@end
