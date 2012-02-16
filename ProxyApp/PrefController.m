//
//  PrefController.m
//  ProxyApp
//
//  Created by Joshua Girard on 1/29/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "PrefController.h"

BOOL ChangedSHK=NO;
BOOL ChangedAPR=NO;

@implementation PrefController

-(id)init{
    if (!(self=[super initWithWindowNibName:@"prefs"])){
		return nil;
    }
    return self;
}

-(void)dealloc{
	[super dealloc];
}

- (void)windowDidLoad {
	[super windowDidLoad];
}

-(IBAction)save:(id)sender{
	[self close];
	standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if(!ChangedSHK){strictHostKeyOn = [standardUserDefaults objectForKey:@"strictHostKey"];}
	if(!ChangedAPR){autoProxyResumeOn = [standardUserDefaults objectForKey:@"autoProxyResume"];}
	if (standardUserDefaults) {
		[standardUserDefaults setObject:[server stringValue] forKey:@"server"];
		[standardUserDefaults setObject:[username stringValue] forKey:@"username"];
		[standardUserDefaults setObject:[password stringValue] forKey:@"password"];
		[standardUserDefaults setObject:[port stringValue] forKey:@"port"];
		[standardUserDefaults setObject:strictHostKeyOn forKey:@"strictHostKey"];
		[standardUserDefaults setObject:autoProxyResumeOn forKey:@"autoProxyResume"];
		[standardUserDefaults synchronize];
		ChangedSHK=NO;
		ChangedAPR=NO;
	}
}

-(IBAction)strictHostKey:(id)sender{
	if([strictHostKey state]==NSOnState){strictHostKeyOn=@"On";}else{strictHostKeyOn=@"Off";}
	ChangedSHK=YES;
}

-(IBAction)autoProxyResume:(id)sender{
	if([autoProxyResume state]==NSOnState){autoProxyResumeOn=@"On";}else{autoProxyResumeOn=@"Off";}
	ChangedAPR=YES;
}

@end