//
//  SpinnerController.m
//  ProxyApp
//
//  Created by Joshua Girard on 3/14/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "SpinnerController.h"

@implementation SpinnerController

- (id)init{
	if (!(self=[super initWithWindowNibName:@"spinner"])){
		return nil;
    }
    return self;
}

- (void)windowDidLoad{
	//[[self window] setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
    [super windowDidLoad];
}

-(void)dealloc{
	[super dealloc];
}

+(id)close{
	[self close];
	return nil;
}

@end
