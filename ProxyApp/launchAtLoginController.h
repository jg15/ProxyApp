//
//  launchAtLoginController.h
//  ProxyApp
//
//  Created by Joshua Girard on 2/1/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface launchAtLoginController : NSObject {}

@property(assign) BOOL launchAtLogin;

- (BOOL) willLaunchAtLogin: (NSURL*) itemURL;
- (void) setLaunchAtLogin: (BOOL) enabled forURL: (NSURL*) itemURL;
void sharedFileListDidChange(LSSharedFileListRef inList, void *context);

@end
