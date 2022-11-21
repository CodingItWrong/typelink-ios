//
//  Page.h
//  TypeLink
//
//  Created by Josh Justice on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Font;

@interface Page : NSObject {
	int pageId;
	NSString *user;
	NSString *title;
	bool publiclyVisible;
	bool shared;
	NSMutableArray *sharedTo; /* of NSString */
	NSMutableArray *aliases; /* of NSString */
	NSString *content;
	NSString *wikiContent;
	Font *font;
}

@property int pageId;
@property (nonatomic,retain) NSString *user;
@property (nonatomic,retain) NSString *title;
@property bool publiclyVisible;
@property bool shared;
@property (nonatomic,retain) NSMutableArray *sharedTo; /* of NSString */
@property (nonatomic,retain) NSMutableArray *aliases; /* of NSString */
@property (nonatomic,retain) NSString *content;
@property (nonatomic,retain) NSString *wikiContent;
@property (nonatomic,retain) Font *font;

+(Page *)pageFromDict:(NSMutableDictionary *)dict;
-(NSMutableDictionary *)asDict;

-(bool)isSharedTo:(NSString *)u;
-(bool)isEditableBy:(NSString *)u;

@end
