//
//  AppController.h
//  ProxyApp
//
//  Created by Joshua Girard on 1/29/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefController.h"

@interface AppController : NSObject{ 
	IBOutlet NSTextField *serverField;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *portField;
	IBOutlet NSButton *strictHostKeyCheckingToggle;
	IBOutlet NSButton *autoProxyResumeToggle;
	
	id ToFill;
	int tempValSHK;
	int tempValAPR;
	
	NSUserDefaults *standardUserDefaults;
	NSString *server;
	NSString *username;
	NSString *password;
	NSString *port;
	NSString *strictHostKey;
	NSString *autoProxyResume;
	
	NSObject *toFill;
	
	NSDictionary *options;
    NSImage *img;
}
@property (assign) IBOutlet NSWindow *prefWindow;
@property (retain) PrefController *prefController;

-(IBAction)showPreferences:(id)sender; 
-(IBAction)about:(id)sender;
-(IBAction)quit:(id)sender;
-(id)fillFields;
@end
