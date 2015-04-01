//
//  AppDelegate.m
//  ProxyApp
//
//  Created by Joshua Girard on 1/26/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "AppDelegate.h"
#import "Keychain.h"
#import "ConfigureSOCKS.h"

BOOL proxyIsOn = NO;
BOOL statusMenuOn = YES;
BOOL autoCheckForUpdates = YES;
BOOL proxyWasOn = NO;
BOOL proxyResume = YES;
//BOOL spinnerIsOn = NO;

@implementation AppDelegate
@synthesize prefWindow, prefController;//, spinWindow, spinnerController;
@synthesize window;// = _window;


-(BOOL) hasNetworkClientEntitlement{
	return YES;
}
-(void)growl:(NSString *)title:(NSString *)msg{
    NSLog(@"%@",msg);
	standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults){
		if([[standardUserDefaults objectForKey:@"growl"] isEqualToString:@"On"]){
			if([[standardUserDefaults objectForKey:@"verboseGrowl"] isEqualToString:@"On"]||[msg isEqualToString:@"CONNECTED"]||[msg isEqualToString:@"DISCONNECTED"]||[msg rangeOfString:@"ERROR:"].location!=NSNotFound){
			NSString *name = @"Message";
                SInt32 versionMinor = 0;
                Gestalt( gestaltSystemVersionMinor, &versionMinor );
                if(versionMinor>7){
                    NSUserNotification *notification = [[NSUserNotification alloc] init];
                    [notification setTitle:title];
                    [notification setInformativeText:msg];
                    [notification setDeliveryDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]]];
                    [notification setSoundName:nil];
                    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
                    [center scheduleNotification:notification];
                    //[center removeDeliveredNotification:notification];
                    notification=nil;
                }
			[msg release];
			[name release];
			[title release];
			}
		}
	}
}
//NSString
//- (void)awakeFromNib{
- (void)begin {
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(receiveSleepNote:) name: NSWorkspaceWillSleepNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(receiveWakeNote:) name: NSWorkspaceDidWakeNotification object: NULL];
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    NSBundle *bundle = [NSBundle mainBundle];
    statusImageOn = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"on" ofType:@"tiff"]];
	statusImageOff = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"off" ofType:@"tiff"]];
	//statusImageChange = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"starting" ofType:@"png"]];
	conImages = [[NSArray alloc] initWithObjects:[[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"con0" ofType:@"tiff"]], [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"con1" ofType:@"tiff"]], [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"con2" ofType:@"tiff"]], nil];
	
	[statusImageOn setTemplate:YES];
	[statusImageOff setTemplate:YES];
	//[statusImageChange setTemplate:YES];
	
	animationActive=NO;
	connectionEstablished=NO;
	
	for (NSImage *frame in conImages) {
		[frame setTemplate:YES];
	}
	//[statusItem ]
	
	
	
    [statusItem setImage:statusImageOff];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Proxy App"];
    [statusItem setHighlightMode:YES];
    [statusItem setTarget:self];
	if(autoCheckForUpdates)[updater checkForUpdatesInBackground];
	//[GrowlApplicationBridge setGrowlDelegate:self]; //Growl Setup
	[self checkOldVersion];
}

-(void)readSshOutput: (NSNotification *)notification{
    NSData *data;
    NSString *text;
	
    if( [notification object] != _fileHandle )
        return;
	
    data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]; 
    text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	if([text isLike:@"CONNECTED"]){
		[self animate:NO];
		[statusItem setImage:statusImageOn];
		connectionEstablished=YES;
		/*
		if(spinnerIsOn){
			[spinner stop];
			[spinner release];
			spinnerIsOn=NO;
		}*/
		[self growl:@"Message:":text];
	}
	
	
	if(![text isLike:@"CONNECTED"]){
		[self growl:@"Message:":text];
	}
	
    //text=nil;
	
	//NSLog(@"%@",text);
	//NSLog(@"%@",sshError);
	
    [text release];
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
		id PrefLauncher=[[AppController alloc] init];
		[PrefLauncher openPreferences];
		[PrefLauncher release];
		/*if(!self.prefController){
			self.prefController = [[PrefController alloc] init];
		}
		[NSApp activateIgnoringOtherApps:YES];
		[[self.prefController window] center];
		[self.prefController showWindow:self];
		[[NSApplication sharedApplication] arrangeInFront:nil];*/
	}else{
		NSEvent *event = [NSApp currentEvent];
		//NSLog(@"Click count: %ld",[event clickCount]);
		statusMenuOn=YES;
		if(([event modifierFlags] & NSAlternateKeyMask)||([NSEvent pressedMouseButtons]==2)){
			statusMenuOn=NO;
			[statusMenu cancelTrackingWithoutAnimation];
			//[statusMenu cancelTrackingWithoutAnimation];
			[statusItem popUpStatusItemMenu:controlMenu];
		}
		
	}
}

-(void)menuDidClose:(NSMenu *)menu{
	if(![menu.title isEqualToString:@"altMenu"])[self proxyToggle];
}

-(void)nextAnimationFrame{
	if(frameSwitcher){
		[statusItem setImage:[conImages objectAtIndex:currentFrame++]];
		if(currentFrame>2){
			frameSwitcher=NO;
			currentFrame=1;
		}
	}else{
		[statusItem setImage:[conImages objectAtIndex:currentFrame--]];
		if(currentFrame<0){
			frameSwitcher=YES;
			currentFrame=1;
		}

	}

}

-(void)animate:(BOOL)on{
	if(on){
		if(!animationActive){
			animationActive=YES;
			currentFrame=0;
			frameSwitcher=YES;
			animationTimer=nil;
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(nextAnimationFrame) userInfo:nil repeats:YES];
		}
	}else{
		[animationTimer invalidate];
		animationTimer=nil;
		animationActive=NO;
	}
}



-(void)proxyToggleOn{
	if(!proxyIsOn){
		proxyIsOn=YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readSshOutput:) name:NSFileHandleReadCompletionNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sshDone:) name:NSTaskDidTerminateNotification object:nil];
	//NSLog(@"AAAAAAAAAAAAAAAAAAAAAA");
	//[statusItem setTitle:@"Starting..."];
	//[statusItem setImage:statusImageChange];
	//[NSThread detachNewThreadSelector:@selector(animate:) toTarget:[self class] withObject:nil];
	[self animate:YES];
	
	//[statusItem set]
	
	/*
	spinner=[[SpinnerDriver alloc] init];
	[spinner start];
	spinnerIsOn=YES;
	*/
	//[spinnerDriver performSelector:@selector(spin:)];
	//system("sudo networksetup -setsocksfirewallproxystate Wi-Fi on");
	
	[ConfigureSOCKS on];
	
	
	
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

	
	//system("sudo networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 7070 off");
	
	
	

	
	//[statusItem setImage:statusImageChange];
	//[statusItem setTitle:@"On"];
	//[statusItem setImage:statusImageOn];
	}
}

-(void)proxyToggleOff{
	if(proxyIsOn){
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
    //NSLog(@"xxx");
	
	/*
	if(spinnerIsOn){
		[spinner stop];
		[spinner release];
		spinnerIsOn=NO;
	}*/
	if(_ssh){
		[_ssh terminate];
		[_ssh release];
	}
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	//[statusItem setTitle:@"Stopping..."];
	//[statusItem setImage:statusImageChange];
	
        _ssh=nil;
        [self animate:YES];
	
	
	/*system("sudo networksetup -setsocksfirewallproxy Wi-Fi '' '' off");
	system("sudo networksetup -setsocksfirewallproxystate Wi-Fi off");*/
	[ConfigureSOCKS off];
	
	
	[self animate:NO];
	[statusItem setImage:statusImageOff];
	//[statusItem setTitle:@""];
	//[statusItem setTitle:@"Off"];
	
	if(connectionEstablished){
		[self growl:@"Message:":@"DISCONNECTED"];
	}/*else{
		[self growl:@"Message:":@""];
	}*/
	proxyIsOn=NO;
	connectionEstablished=NO;
	
	NSLog(@"Stopping Proxy");
	}
}

-(void)proxyToggle{	
	if(statusMenuOn){
		standardUserDefaults = [NSUserDefaults standardUserDefaults];
		if (standardUserDefaults){
			server = [standardUserDefaults objectForKey:@"server"];
			username = [standardUserDefaults objectForKey:@"username"];
			//password = [standardUserDefaults objectForKey:@"password"];
			password = [keychain getItem:@"ProxyApp"];
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

-(void)checkOldVersion{
	standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if(standardUserDefaults){
		if([standardUserDefaults objectForKey:@"password"]){
			NSRunAlertPanel(@"Message:", @"You have just upgraded ProxyApp! Will now attempt to move your password to the Keychain and setup new configuration.", @"OK", nil, nil);
			[keychain setItem:@"ProxyApp" withPassword:[standardUserDefaults objectForKey:@"password"]];
			[standardUserDefaults removeObjectForKey:@"password"];
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
	//[statusImageChange release];
	[conImages release];
	[statusItem release];
    //[statusHighlightImage release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [self begin];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification{
    [center removeDeliveredNotification:notification];
}
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [center removeDeliveredNotification:notification];
    });
}

@end