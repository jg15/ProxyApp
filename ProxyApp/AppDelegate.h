//
//  AppDelegate.h
//  ProxyApp
//
//  Created by Joshua Girard on 1/26/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import <Sparkle/SUUpdater.h>
#import <Growl/Growl.h>

#import "PrefController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,GrowlApplicationBridgeDelegate> {
	IBOutlet SUUpdater *updater;
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenu *controlMenu;
    NSStatusItem *statusItem;
    NSImage *statusImageOn;
	NSImage *statusImageOff;
	NSImage *statusImageChange;
	NSTask *_ssh;
	NSPipe *sshOutput;
	NSFileHandle *_fileHandle;
	NSUserDefaults *standardUserDefaults;
	NSString *server;
	NSString *username;
	NSString *password;
	NSString *port;
	NSString *strictHostKey;
	NSString *autoProxyResume;
	NSString *arg;
	NSString *arg2;
	NSString *askPassPath;
	NSArray *args;
	NSString *preargs;
    //NSImage *statusHighlightImage;
}

//-(void)menuDidClose:(NSMenu *)theMenu;

@property (assign) IBOutlet NSWindow *prefWindow;
@property (retain) PrefController *prefController;
@property (assign) IBOutlet NSWindow *window;

@end