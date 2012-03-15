//
//  SpinnerController.h
//  ProxyApp
//
//  Created by Joshua Girard on 3/14/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SpinnerController : NSWindowController <NSWindowDelegate>{
	IBOutlet NSWindow *spinWindow;
}
+(id)close;
@end
