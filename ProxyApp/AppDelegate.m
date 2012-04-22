//
//  AppDelegate.m
//  ProxyApp
//
//  Created by Joshua Girard on 1/26/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "AppDelegate.h"

BOOL proxyIsOn = NO;
BOOL statusMenuOn = YES;
BOOL autoCheckForUpdates = YES;
BOOL proxyWasOn = NO;
BOOL proxyResume = YES;
BOOL spinnerIsOn = NO;

@implementation AppDelegate
@synthesize prefWindow, prefController;//, spinWindow, spinnerController;
@synthesize window = _window;

- (NSDictionary *)registrationDictionaryForGrowl {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Growl Registration Ticket" ofType:@"growlRegDict"]];
}

-(void)growl:(NSString *)title:(NSString *)msg{
	standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults){
		if([[standardUserDefaults objectForKey:@"growl"] isEqualToString:@"On"]){
			if([[standardUserDefaults objectForKey:@"verboseGrowl"] isEqualToString:@"On"]||[msg isEqualToString:@"CONNECTED"]||[msg isEqualToString:@"DISCONNECTED"]){
			NSString *name = @"Message";
			[GrowlApplicationBridge notifyWithTitle:title description:msg notificationName:name iconData:nil priority:0 isSticky:NO clickContext:nil];
			[msg release];
			[name release];
			[title release];
			}
		}
	}
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
    [statusItem setImage:statusImageOff];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Proxy App"];
    [statusItem setHighlightMode:YES];
    [statusItem setTarget:self];
	if(autoCheckForUpdates)[updater checkForUpdatesInBackground];
	[GrowlApplicationBridge setGrowlDelegate:self]; //Growl Setup
}

-(void)readSshOutput: (NSNotification *)notification{
    NSData *data;
    NSString *text;
	
    if( [notification object] != _fileHandle )
        return;
	
    data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]; 
    text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	if([text isLike:@"CONNECTED"]){
		[statusItem setImage:statusImageOn];
		if(spinnerIsOn){
			[spinner stop];
			[spinner release];
			spinnerIsOn=NO;
		}
	}
	
	[self growl:@"Message:":text];
	NSLog(@"%@",text);
	//NSLog(@"%@",sshError);
	
    //[text release];
    if(proxyIsOn){
        [_fileHandle readInBackgroundAndNotify];
	}
}

-(void)sshDone: (NSNotification *)notification{
	//NSLog(@"Status: %i",[[notification object] terminationStatus]);
	[self proxyToggleOff];
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
	[self proxyToggle];
}

-(void)proxyToggleOn{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readSshOutput:) name:NSFileHandleReadCompletionNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sshDone:) name:NSTaskDidTerminateNotification object:nil];
	//[statusItem setTitle:@"Starting..."];
	[statusItem setImage:statusImageChange];
	spinner=[[SpinnerDriver alloc] init];
	[spinner start];
	spinnerIsOn=YES;
	//[spinnerDriver performSelector:@selector(spin:)];
	system("networksetup -setsocksfirewallproxystate Wi-Fi on");
	_ssh = [NSTask new];
	sshOutput = [NSPipe pipe];
	sshError = [NSPipe pipe];
	_fileHandle = [sshOutput fileHandleForReading];
	[_fileHandle readInBackgroundAndNotify];
	_fileHandleError = [sshError fileHandleForReading];
	[_fileHandleError readInBackgroundAndNotify];
	[_ssh setStandardOutput: sshOutput];
	[_ssh setStandardError: sshError];
	[_ssh setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
	
	/*if([password isEqualToString:@""]){
	 preargs = [NSString stringWithFormat:@"%@@%@",username,server];
	 args = [NSArray arrayWithObjects:@"-NTp",port,preargs,@"-D",@"7070",@"-o",@"KeepAlive yes",@"-o",arg,@"-o",arg2,nil];
	 [_ssh setLaunchPath:@"/usr/bin/ssh"];
	 }else{*/
	if([password isEqualToString:@""])password=NULL;
	args = [NSArray arrayWithObjects:port,server,username,arg,arg2,password,nil];
	[_ssh setLaunchPath:[NSBundle pathForResource:@"ssh_connect" ofType:@"" inDirectory:[[NSBundle mainBundle] bundlePath]]];
	//}
	
	NSLog(@"Starting Proxy");
	[_ssh setArguments:args];
	[_ssh launch];
	system("networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 7070 off");
	//[statusItem setImage:statusImageChange];
	//[statusItem setTitle:@"On"];
	//[statusItem setImage:statusImageOn];
	proxyIsOn=YES;
}

-(void)proxyToggleOff{
	if(spinnerIsOn){
		[spinner stop];
		[spinner release];
		spinnerIsOn=NO;
	}
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
	[self growl:@"Message:":@"DISCONNECTED"];
	NSLog(@"Stopping Proxy");
}

-(void)proxyToggle{	
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
				[self proxyToggleOff];
			}else{
				[self proxyToggleOn];
			}
		}
    }
}

-(void)receiveSleepNote:(NSNotification*)note{
	NSLog(@"receiveSleepNote: %@", [note name]);
	if(proxyIsOn){
		[self proxyToggleOff];
		proxyWasOn=YES;
	}
}

-(void)receiveWakeNote:(NSNotification*)note{
	NSLog(@"receiveSleepNote: %@", [note name]);
	if(proxyWasOn){
		if(proxyIsOn){
			[self proxyToggleOff];
		}
		if(proxyResume){
			[self performSelector:@selector(proxyToggleOn) withObject:nil afterDelay:5.0];
			proxyWasOn=NO;
		}
	}
}

-(void)applicationWillTerminate:(NSApplication *)sender {
	if(proxyIsOn){
		/*system("networksetup -setsocksfirewallproxy Wi-Fi '' '' off");
		system("networksetup -setsocksfirewallproxystate Wi-Fi off");
		[_ssh terminate];
		[_ssh release];*/
		[self proxyToggle];
	}
	
}

- (void)dealloc{
	//[spinStarter release];
    [statusImageOn release];
	[statusImageOff release];
	[statusImageChange release];
	[statusItem release];
    //[statusHighlightImage release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end