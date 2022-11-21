//
//  TypeLinkService.h
//  TypeLink
//
//  Created by Josh Justice on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeLinkConnection.h"
@class SBJsonParser;
@class SBJsonWriter;
@class Page;
@class Settings;
@class TypeLinkConnection;

@interface TypeLinkService : NSObject {
	SBJsonParser *parser;
	SBJsonWriter *writer;
	Settings *settings;
	NSString *apiUrl;
}

@property (nonatomic,retain) SBJsonParser *parser;
@property (nonatomic,retain) SBJsonWriter *writer;
@property (nonatomic,retain) Settings *settings;
@property (nonatomic,retain) NSString *apiUrl;

+(TypeLinkService *)currentService;
+(void)setCurrentService:(TypeLinkService *)currentService;

-(id)initWithApiUrl:(NSString *)apiUrl
		   settings:(Settings *)settings;

-(TypeLinkConnection *)registerUser:(User *)user
					   withDelegate:(id)delegate;

-(TypeLinkConnection *)getAccountWithDelegate:(id)delegate;

-(TypeLinkConnection *)saveAccount:(User *)user
                      withDelegate:(id)delegate;

-(TypeLinkConnection *)getFontsWithDelegate:(id)delegate;

-(TypeLinkConnection *)listPagesForUser:(NSString *)user
							   delegate:(id)delegate;

-(TypeLinkConnection *)listPagesSharedToUser:(NSString *)user
									delegate:(id)delegate;

-(TypeLinkConnection *)createPage:(Page *)p
						  forUser:(NSString *)u
						 delegate:(id)delegate;

-(TypeLinkConnection *)getPageForUser:(NSString *)user
							withTitle:(NSString *)title
							 delegate:(id)delegate;

-(TypeLinkConnection *)savePage:(Page *)page
					  withTitle:(NSString *)title
					   delegate:(id)delegate;

-(TypeLinkConnection *)deletePageForUser:(NSString *)u
							   withTitle:(NSString *)t
								delegate:(id)delegate;

-(TypeLinkConnection *)sharePage:(Page *)p
						  toUser:(NSString *)user
						delegate:(id)delegate;

-(TypeLinkConnection *)unsharePage:(Page *)p
						  fromUser:(NSString *)user
						  delegate:(id)delegate;

-(TypeLinkConnection *)addAlias:(NSString *)alias
						 toPage:(Page *)page
					   delegate:(id)delegate;

-(TypeLinkConnection *)removeAlias:(NSString *)alias
						  fromPage:(Page *)page
						  delegate:(id)delegate;

@end
