//
//  Settings.m
//  TypeLinkData
//
//  Created by Josh Justice on 7/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"


@implementation Settings
@dynamic username;
@dynamic password;
@dynamic lock;
@dynamic fontSize;

static Settings *currentSettings = nil;

+(Settings *)currentSettings {
	return currentSettings;
}
+(void)setCurrentSettings:(Settings *)settings {
	currentSettings = settings;
}

@end
