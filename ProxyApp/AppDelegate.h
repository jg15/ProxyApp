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

#import "AppController.h"
#import "PrefController.h"
#import "SpinnerDriver.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSUserNotificationCenterDelegate> {
	IBOutlet SUUpdater *updater;
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenu *controlMenu;
    NSStatusItem *statusItem;
    NSImage *statusImageOn;
	NSImage *statusImageOff;
	//NSImage *statusImageChange;
	NSArray *conImages;
	NSTask *_ssh;
	NSPipe *sshOutput;
	NSPipe *sshError;
	NSFileHandle *_fileHandle;
	NSFileHandle *_fileHandleError;
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
	SpinnerDriver *spinner;
	
	NSWindow *prefWindow;
	PrefController *prefController;
	NSWindow *window;
	
	NSInteger currentFrame;
	BOOL frameSwitcher;
	BOOL animationActive;
	
	NSTimer *animationTimer;
	
	BOOL connectionEstablished;
	
}
-(BOOL) hasNetworkClientEntitlement;
-(void)growl:(NSString *)title:(NSString *)msg;
-(void)proxyToggle;
-(void)proxyToggleOn;
-(void)proxyToggleOff;
-(void)checkOldVersion;

-(void)nextAnimationFrame;

@property (assign) IBOutlet NSWindow *prefWindow;
@property (retain) PrefController *prefController;
@property (assign) IBOutlet NSWindow *window;

@end