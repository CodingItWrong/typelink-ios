//
//  Page.m
//  TypeLink
//
//  Created by Josh Justice on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Page.h"
#import "Font.h"

#define ID_KEY @"id"
#define USER_KEY @"user"
#define TITLE_KEY @"title"
#define PUBLICLY_VISIBLE_KEY @"publiclyVisible"
#define SHARED_KEY @"shared"
#define SHARED_TO_KEY @"sharedTo"
#define ALIASES_KEY @"aliases"
#define CONTENT_KEY @"content"
#define WIKI_CONTENT_KEY @"wikiContent"
#define FONT_KEY @"font"

@implementation Page

@synthesize pageId;
@synthesize user;
@synthesize title;
@synthesize publiclyVisible;
@synthesize shared;
@synthesize sharedTo;
@synthesize aliases;
@synthesize content;
@synthesize wikiContent;
@synthesize font;

+(Page *)pageFromDict:(NSMutableDictionary *)dict {
	Page *page = [[Page alloc] init];
	if( page ) {
		page.pageId = [[dict objectForKey:ID_KEY] intValue];
		page.user = [dict objectForKey:USER_KEY];
		page.title = [dict objectForKey:TITLE_KEY];
		page.publiclyVisible = [[dict objectForKey:PUBLICLY_VISIBLE_KEY] boolValue];
		page.shared = [[dict objectForKey:SHARED_KEY] boolValue];
		page.sharedTo = [dict objectForKey:SHARED_TO_KEY];
		page.aliases = [dict objectForKey:ALIASES_KEY];
		page.content = [dict objectForKey:CONTENT_KEY];
		page.wikiContent = [dict objectForKey:WIKI_CONTENT_KEY];
		page.font = [Font fontFromDict:[dict objectForKey:FONT_KEY]];
	}
	return page;
}
-(NSMutableDictionary *)asDict {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
	[dict setObject:[NSNumber numberWithInt:pageId] forKey:ID_KEY];
	if( title ) {
		[dict setObject:title forKey:TITLE_KEY];
	}
	[dict setObject:[NSNumber numberWithBool:publiclyVisible] forKey:PUBLICLY_VISIBLE_KEY];
	if( content ) {
		[dict setObject:content forKey:CONTENT_KEY];
	}
	if( nil == font ) {
		[dict setObject:[NSNull null] forKey:FONT_KEY];
	} else {
		[dict setObject:[font asDict] forKey:FONT_KEY];
	}
	// do not save wiki content to server
	return dict;
}

-(bool)isSharedTo:(NSString *)u {
	if( nil == sharedTo ) {
		return false;
	}
	
	NSEnumerator *enumerator = [sharedTo objectEnumerator];
	NSString *testUser;
	while( testUser = [enumerator nextObject] ) {
		if( [testUser isEqualToString:u] ) {
			return true;
		}
	}
	return false;
}

-(bool)isEditableBy:(NSString *)u {
	if( [user isEqualToString:u] ) {
		return true;
	} else {
		return [self isSharedTo:u];
	}
}

@end
