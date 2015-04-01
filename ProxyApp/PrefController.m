//
//  PrefController.m
//  ProxyApp
//
//  Created by Joshua Girard on 1/29/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "PrefController.h"
#import "Keychain.h"

static int numberOfShakes = 4;
static float durationOfShake = 0.5f;
static float vigourOfShake = 0.05f;

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

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
	
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
	int index;
	for (index = 0; index < numberOfShakes; ++index)
	{
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
	}
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    return shakeAnimation;
}

-(IBAction)save:(id)sender{
	BOOL serverCheck = [[server stringValue] isEqualToString:@""];
	BOOL serverDotCheck = [[server stringValue] rangeOfString:@"."].location == NSNotFound;
	BOOL usernameCheck = [[username stringValue] isEqualToString:@""];
	if(serverCheck||serverDotCheck||usernameCheck){
		[prefWindow setAnimations:[NSDictionary dictionaryWithObject:[self shakeAnimation:[prefWindow frame]] forKey:@"frameOrigin"]];
		[[prefWindow animator] setFrameOrigin:[prefWindow frame].origin];
		if(serverCheck){
			[prefWindow makeFirstResponder:server];
		}else if(serverDotCheck){
			[prefWindow makeFirstResponder:server];
		}else{
			[prefWindow makeFirstResponder:username];
		}
	}else{
		[self close];
		standardUserDefaults = [NSUserDefaults standardUserDefaults];
		if(!ChangedSHK){strictHostKeyOn = [standardUserDefaults objectForKey:@"strictHostKey"];}
		if(!ChangedAPR){autoProxyResumeOn = [standardUserDefaults objectForKey:@"autoProxyResume"];}
		if(!ChangedGrowl){growlOn = [standardUserDefaults objectForKey:@"growl"];}
		if (standardUserDefaults) {
			[standardUserDefaults setObject:[server stringValue] forKey:@"server"];
			[standardUserDefaults setObject:[username stringValue] forKey:@"username"];
			//[standardUserDefaults setObject:[password stringValue] forKey:@"password"];
			[keychain setItem:@"ProxyApp" withPassword:[password stringValue]];
			[standardUserDefaults setObject:[port stringValue] forKey:@"port"];
			[standardUserDefaults setObject:strictHostKeyOn forKey:@"strictHostKey"];
			[standardUserDefaults setObject:autoProxyResumeOn forKey:@"autoProxyResume"];
			[standardUserDefaults setObject:growlOn forKey:@"growl"];
			[standardUserDefaults setObject:verboseGrowlOn forKey:@"verboseGrowl"];
			[standardUserDefaults synchronize];
			ChangedSHK=NO;
			ChangedAPR=NO;
			ChangedGrowl=NO;
		}
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
	if([growl state]==NSOnState){
		growlOn=@"On";
		[verboseGrowl setEnabled:YES];
	}else{
		[verboseGrowl setEnabled:NO];
		growlOn=@"Off";
	}
	ChangedGrowl=YES;
}

-(IBAction)verboseGrowl:(id)sender{
	if([verboseGrowl state]==NSOnState){verboseGrowlOn=@"On";}else{verboseGrowlOn=@"Off";}
}
@end