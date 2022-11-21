//
//  Font.m
//  TypeLinkData
//
//  Created by Josh Justice on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Font.h"

#define ID_KEY @"id"
#define NAME_KEY @"name"
#define IOS_CODE_KEY @"iOSCode"
#define CSS_CODE_KEY @"cssCode"

@implementation Font

@synthesize fontId;
@synthesize name;
@synthesize iOSCode;
@synthesize cssCode;

static NSArray *allFonts = nil;

+(Font *)fontFromDict:(NSMutableDictionary *)dict {
	if( nil == dict || [dict isMemberOfClass:[NSNull class]] ) {
		return nil;
	}
	Font *font = [[Font alloc] init];
	if( font ) {
		font.fontId = [[dict objectForKey:ID_KEY] intValue];
		font.name = [dict objectForKey:NAME_KEY];
		font.iOSCode = [dict objectForKey:IOS_CODE_KEY];
		font.cssCode = [dict objectForKey:CSS_CODE_KEY];
	}
	return font;
}
-(NSMutableDictionary *)asDict {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:1];
	[dict setObject:[NSNumber numberWithInt:fontId] forKey:ID_KEY];
	return dict;
}


+(NSArray *)allFonts {
	return allFonts;
}

+(void)setAllFonts:(NSArray *)f {
	allFonts = f;
}

@end
