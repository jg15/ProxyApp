//
//  Keychain.h
//  ProxyApp
//
//  Created by Joshua Girard on 3/19/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface keychain : NSObject <NSApplicationDelegate>

+(BOOL)setItem:(NSString *)serviceName withPassword:(NSString *)password;
+(BOOL)addItem:(NSString *)serviceName withPassword:(NSString *)password;
+(NSString *)getItem:(NSString *)serviceName;
+(BOOL)deleteItem:(NSString *)serviceName;
+(BOOL)modifyItem:(NSString *)serviceName withNewPassword:(NSString *)newPassword;

@end
