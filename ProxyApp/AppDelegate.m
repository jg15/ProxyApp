//
//  AppDelegate.m
//  ProxyApp
//
//  Created by Joshua Girard on 1/26/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "AppDelegate.h"

/*#include <IOKit/pwr_mgt/IOPMLib.h>
#include <IOKit/IOMessage.h>*/


BOOL proxyIsOn = NO;
BOOL statusMenuOn = YES;
BOOL autoCheckForUpdates = YES;
BOOL proxyWasOn = NO;
BOOL proxyResume = YES;

@implementation AppDelegate
@synthesize prefWindow, prefController;
@synthesize window = _window;

- (NSDictionary *)registrationDictionaryForGrowl {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Growl Registration Ticket" ofType:@"growlRegDict"]];
}

-(void)growl:(NSString *)title:(NSString *)msg{
	NSString *name = @"Message";
	[GrowlApplicationBridge notifyWithTitle:title description:msg notificationName:name iconData:nil priority:0 isSticky:NO clickContext:nil];
	[msg release];
	[name release];
	[title release];
}

- (void)awakeFromNib{
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(receiveSleepNote:) name: NSWorkspaceWillSleepNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(receiveWakeNote:) name: NSWorkspaceDidWakeNotification object: NULL];
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    NSBundle *bundle = [NSBundle mainBundle];
    statusImageOn = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"on" ofType:@"png"]];
	statusImageOff = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"off" ofType:@"png"]];
	statusImageChange = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"starting" ofType:@"png"]];
	[statusImageOn setTemplate:YES];
	[statusImageOff setTemplate:YES];
	[statusImageChange setTemplate:YES];
    //statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ForwardArrowIcon2" ofType:@"png"]];
    [statusItem setImage:statusImageOff];
    //[statusItem setAlternateImage:statusHighlightImage];
    
    //[statusItem setTitle:@"Off"];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Proxy App"];
    [statusItem setHighlightMode:YES];
    [statusItem setTarget:self];
	if(autoCheckForUpdates)[updater checkForUpdatesInBackground];
	[GrowlApplicationBridge setGrowlDelegate:self]; //Growl Setup
}

-(void)readSshOutput: (NSNotification *)notification
{
    NSData *data;
    NSString *text;
	
    if( [notification object] != _fileHandle )
        return;
	
    data = [[notification userInfo] 
            objectForKey:NSFileHandleNotificationDataItem];
    text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	[self growl:@"Message:":text];
	//NSLog(@"%@",text);
	
    //[text release];
    if(proxyIsOn){
        [_fileHandle readInBackgroundAndNotify];
	}
}

-(void)menuWillOpen:(NSMenu *)theMenu{
	standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if(!([standardUserDefaults objectForKey:@"server"]&&[standardUserDefaults objectForKey:@"username"])){
		NSRunAlertPanel(@"Note:", @"You have not set preferences yet. Please do so now.", @"Open Preferences", nil, nil);
		if(!self.prefController){
			self.prefController = [[PrefController alloc] init];
		}
		[NSApp activateIgnoringOtherApps:YES];
		[[self.prefController window] center];
		[self.prefController showWindow:self];
		[[NSApplication sharedApplication] arrangeInFront:nil];
	}else{
		statusMenuOn=YES;
		NSEvent *event = [NSApp currentEvent];
		//NSLog(@"Click count: %ld",[event clickCount]);
		if(([event modifierFlags] & NSCommandKeyMask)||([NSEvent pressedMouseButtons]==2)){
			[statusMenu cancelTrackingWithoutAnimation];
			[statusItem popUpStatusItemMenu:controlMenu];
			statusMenuOn=NO;
		}
	}
}

-(void)menuDidClose:(NSMenu *)theMenu{
	if(statusMenuOn){
		standardUserDefaults = [NSUserDefaults standardUserDefaults];
		if (standardUserDefaults){
			server = [standardUserDefaults objectForKey:@"server"];
			username = [standardUserDefaults objectForKey:@"username"];
			password = [standardUserDefaults objectForKey:@"password"];
			port = [standardUserDefaults objectForKey:@"port"];
			strictHostKey = [standardUserDefaults objectForKey:@"strictHostKey"];
			autoProxyResume = [standardUserDefaults objectForKey:@"autoProxyResume"];
			if([port isEqualToString:@""]){port=@"22";}
			if([strictHostKey isEqualToString:@"On"]){arg=@"StrictHostKeyChecking no";arg2=@"UserKnownHostsFile=/dev/null";}else{arg=@"";arg2=@"";}
			if([autoProxyResume isEqualToString:@"Off"]){proxyResume=NO;}else{proxyResume=YES;}
		}	
		if(server&&username){
			if(proxyIsOn){
				[[NSNotificationCenter defaultCenter] removeObserver:self];
				//[statusItem setTitle:@"Stopping..."];
				[statusItem setImage:statusImageChange];
				[_ssh terminate];
				[_ssh release];
				system("networksetup -setsocksfirewallproxy Wi-Fi '' '' off");
				system("networksetup -setsocksfirewallproxystate Wi-Fi off");
				[statusItem setImage:statusImageOff];
				//[statusItem setTitle:@""];
				//[statusItem setTitle:@"Off"];
				proxyIsOn=NO;
				NSLog(@"Stopping Proxy");
			}else{
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readSshOutput:) name:NSFileHandleReadCompletionNotification object:nil];
				//[statusItem setTitle:@"Starting..."];
				[statusItem setImage:statusImageChange];
				system("networksetup -setsocksfirewallproxystate Wi-Fi on");
				_ssh = [NSTask new];
				sshOutput = [NSPipe pipe];
				_fileHandle = [sshOutput fileHandleForReading];
				[_fileHandle readInBackgroundAndNotify];
				[_ssh setStandardOutput: sshOutput];
				[_ssh setStandardError: sshOutput];
				[_ssh setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
			
				if([password isEqualToString:@""]){
					preargs = [NSString stringWithFormat:@"%@@%@",username,server];
					args = [NSArray arrayWithObjects:@"-NTp",port,preargs,@"-D",@"7070",@"-o",@"KeepAlive yes",@"-o",arg,@"-o",arg2,nil];
					[_ssh setLaunchPath:@"/usr/bin/ssh"];
				}else{
					args = [NSArray arrayWithObjects:port,server,username,arg,arg2,password,nil];
					[_ssh setLaunchPath:[NSBundle pathForResource:@"ssh_password_login" ofType:@"" inDirectory:[[NSBundle mainBundle] bundlePath]]];
				}
			
				NSLog(@"Starting Proxy");
				[_ssh setArguments:args];
				[_ssh launch];
				system("networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 7070 off");
				[statusItem setImage:statusImageOn];
				//[statusItem setTitle:@""];
				//[statusItem setTitle:@"On"];
				proxyIsOn=YES;
				//[self growl:@"Hjjjjj":@"NOM"];
			}
		}
    }
}

-(void)receiveSleepNote:(NSNotification*)note{
	NSLog(@"receiveSleepNote: %@", [note name]);
	if(proxyIsOn){
		[self menuDidClose:statusMenu];
		proxyWasOn=YES;
	}
}

-(void)receiveWakeNote:(NSNotification*)note{
	NSLog(@"receiveSleepNote: %@", [note name]);
	if(proxyWasOn&&proxyResume){
		if(proxyIsOn){
			[_ssh terminate];
			[_ssh release];
		}
		sleep(5);
		[self menuDidClose:statusMenu];
		
		proxyWasOn=NO;
	}
}

-(void)applicationWillTerminate:(NSApplication *)sender {
	if(proxyIsOn){
		system("networksetup -setsocksfirewallproxy Wi-Fi '' '' off");
		system("networksetup -setsocksfirewallproxystate Wi-Fi off");
		[_ssh terminate];
		[_ssh release];
	}
	
}

- (void)dealloc{
    [statusImageOn release];
	[statusImageOff release];
	[statusImageChange release];
	[statusItem release];
    //[statusHighlightImage release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end