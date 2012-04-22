//
//  PrefController.h
//  ProxyApp
//
//  Created by Joshua Girard on 1/29/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Cocoa/Cocoa.h>

@interface PrefController : NSWindowController <NSWindowDelegate, NSObject> {
	IBOutlet NSWindow *prefWindow;
	IBOutlet id strictHostKey;
	IBOutlet id server;
    IBOutlet id username;
    IBOutlet id password;
    IBOutlet id port;
	IBOutlet id autoProxyResume;
	IBOutlet id growl;
	IBOutlet id verboseGrowl;
	NSString *strictHostKeyOn;
	NSString *autoProxyResumeOn;
	NSString *growlOn;
	NSString *verboseGrowlOn;
	NSUserDefaults *standardUserDefaults;
	float masterX;
}

-(IBAction)save:(id)sender;
-(IBAction)strictHostKey:(id)sender;
-(IBAction)autoProxyResume:(id)sender;
-(IBAction)growl:(id)sender;
-(IBAction)verboseGrowl:(id)sender;

@end
