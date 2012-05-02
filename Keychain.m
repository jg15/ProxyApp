//
//  Keychain.m
//	ProxyApp
//
//  Created by Joshua Girard on 3/19/12.
//  Copyright (c) 2012 Joshua Girard. All rights reserved.
//

#import "Keychain.h"

@implementation keychain

+(BOOL)setItem:(NSString *)serviceName withPassword:(NSString *)password{
	if(![password isEqualToString:@""]){
		if([self getItem:serviceName]!=NULL){
			return [self modifyItem:serviceName withNewPassword:password];
		}else{
			return [self addItem:serviceName withPassword:password];
		}
	}else{
		return [self deleteItem:serviceName];
	}
}

+(BOOL)addItem:(NSString *)serviceName withPassword:(NSString *)password{
	OSStatus status;
	SecKeychainRef keychain=NULL;
	SecKeychainItemRef itemRef;
	
	
	status=SecKeychainAddGenericPassword(keychain, strlen([serviceName UTF8String]), [serviceName UTF8String], 0, NULL, strlen([password UTF8String]), [password UTF8String], &itemRef);
	
	if(status==noErr){
		CFRelease(itemRef);
	}
	return !status;
}
+(NSString *)getItem:(NSString *)serviceName{
	OSStatus status;
	SecKeychainRef keychain=NULL;
	char* passwordFind;
	UInt32 passwordFindLen;
	NSString *password;
	
	status=SecKeychainFindGenericPassword(keychain, strlen([serviceName UTF8String]), [serviceName UTF8String], 0, NULL, &passwordFindLen, (void *)&passwordFind, NULL);
	if(status==noErr){
		int i=0;
		char pass[3000]="\0";
		while(strlen(pass)!=passwordFindLen){
			pass[i]=passwordFind[i];
			i++;
		}
		password = [NSString stringWithUTF8String:pass];
		SecKeychainItemFreeContent(NULL, passwordFind);
		return password;
	}else{
		return nil;
	}
}
+(BOOL)deleteItem:(NSString *)serviceName{
	OSStatus status;
	SecKeychainItemRef keychainItem;
	SecKeychainRef keychain=NULL;
	
	status=SecKeychainFindGenericPassword(keychain, strlen([serviceName UTF8String]), [serviceName UTF8String], 0, NULL, NULL, NULL, &keychainItem);
	if(status==noErr){
		SecKeychainItemDelete(keychainItem);
		CFRelease(keychainItem);
	}
	return !status;
}
+(BOOL)modifyItem:(NSString *)serviceName withNewPassword:(NSString *)newPassword{
	OSStatus status;
	SecKeychainItemRef keychainItem;
	SecKeychainRef keychain=NULL;
	
	status=SecKeychainFindGenericPassword(keychain, strlen([serviceName UTF8String]), [serviceName UTF8String], 0, NULL, NULL, NULL, &keychainItem);
	if(status==noErr){
		SecKeychainItemModifyAttributesAndData(keychainItem, NULL, strlen([newPassword UTF8String]), [newPassword UTF8String]);
		CFRelease(keychainItem);
	}
	return !status;
}

@end
