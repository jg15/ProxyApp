//
//  PrefController.h
//  ProxyApp
//
//  Created by Joshua Girard on 1/29/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefController : NSWindowController <NSWindowDelegate> {
	IBOutlet id strictHostKey;
	IBOutlet id server;
    IBOutlet id username;
    IBOutlet id password;
    IBOutlet id port;
	IBOutlet id autoProxyResume;
	NSString *strictHostKeyOn;
	NSString *autoProxyResumeOn;
	NSUserDefaults *standardUserDefaults;
}

-(IBAction)save:(id)sender;
-(IBAction)strictHostKey:(id)sender;
-(IBAction)autoProxyResume:(id)sender;

@end
