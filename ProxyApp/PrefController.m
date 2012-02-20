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
BOOL ChangedGrowl=NO;

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
	if(!ChangedGrowl){growlOn = [standardUserDefaults objectForKey:@"growl"];}
	if (standardUserDefaults) {
		[standardUserDefaults setObject:[server stringValue] forKey:@"server"];
		[standardUserDefaults setObject:[username stringValue] forKey:@"username"];
		[standardUserDefaults setObject:[password stringValue] forKey:@"password"];
		[standardUserDefaults setObject:[port stringValue] forKey:@"port"];
		[standardUserDefaults setObject:strictHostKeyOn forKey:@"strictHostKey"];
		[standardUserDefaults setObject:autoProxyResumeOn forKey:@"autoProxyResume"];
		[standardUserDefaults setObject:growlOn forKey:@"growl"];
		[standardUserDefaults synchronize];
		ChangedSHK=NO;
		ChangedAPR=NO;
		ChangedGrowl=NO;
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

-(IBAction)growl:(id)sender{
	if([growl state]==NSOnState){growlOn=@"On";}else{growlOn=@"Off";}
	ChangedGrowl=YES;
}
@end