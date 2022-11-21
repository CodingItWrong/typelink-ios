//
//  User.h
//  TypeLinkData
//
//  Created by Josh Justice on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Font;

@interface User : NSObject {
	NSString *login;
	NSString *email;
	NSString *password;
	Font *defaultFont;
    BOOL sendEmails;
}

@property (nonatomic,retain) NSString *login;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *password;
@property (nonatomic,retain) Font *defaultFont;
@property (nonatomic,assign) BOOL sendEmails;

+(User *)userFromDict:(NSMutableDictionary *)dict;
-(NSMutableDictionary *)asDict;

+(User *)currentUser;
+(void)setCurrentUser:(User *)user;

@end
