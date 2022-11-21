//
//  User.m
//  TypeLinkData
//
//  Created by Josh Justice on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Font.h"

#define LOGIN_KEY @"login"
#define EMAIL_KEY @"email"
#define PASSWORD_KEY @"password"
#define DEFAULT_FONT_KEY @"defaultFont"
#define SEND_EMAILS_KEY @"sendEmails"

@implementation User

@synthesize login;
@synthesize email;
@synthesize password;
@synthesize defaultFont;
@synthesize sendEmails;

static User *currentUser = nil;

+(User *)userFromDict:(NSMutableDictionary *)dict {
	User *user = [[User alloc] init];
	if( user ) {
		user.login = [dict objectForKey:LOGIN_KEY];
		user.email = [dict objectForKey:EMAIL_KEY];
		user.defaultFont = [Font fontFromDict:[dict objectForKey:DEFAULT_FONT_KEY]];
        user.sendEmails = [[dict objectForKey:SEND_EMAILS_KEY] boolValue];
	}
	return user;
}

-(NSMutableDictionary *)asDict {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
	[dict setObject:login forKey:LOGIN_KEY];
	[dict setObject:email forKey:EMAIL_KEY];
    if( nil != password ) {
        [dict setObject:password forKey:PASSWORD_KEY];
    }
    if( nil != defaultFont ) {
        [dict setObject:[defaultFont asDict] forKey:DEFAULT_FONT_KEY];
    }
    [dict setObject:[[NSNumber alloc] initWithBool:sendEmails] forKey:SEND_EMAILS_KEY];
	return dict;
}

+(User *)currentUser {
	return currentUser;
}
+(void)setCurrentUser:(User *)user {
	currentUser = user;
}

@end
