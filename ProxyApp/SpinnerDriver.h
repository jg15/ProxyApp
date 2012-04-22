//
//  SpinnerDriver.h
//  ProxyApp
//
//  Created by Joshua Girard on 3/15/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpinnerController.h"

@interface SpinnerDriver : NSObject{
	id spinStarter;
	IBOutlet id spinner;
	NSWindow *spinWindow;
}

-(id)ToSpin;
-(id)start;
-(id)stop;

@property (assign) IBOutlet NSWindow *spinWindow;
@property (retain) SpinnerController *spinnerController;

@end
