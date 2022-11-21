//
//  TypeLinkConnection.h
//  TypeLinkData
//
//  Created by Josh Justice on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncRestConnectionDelegate.h"
@class SBJsonParser;
@class SBJsonWriter;
@class Page;
@class User;
@protocol TypeLinkConnectionDelegate;

@interface TypeLinkConnection : NSObject
	<AsyncRestConnectionDelegate>
{
	NSString *apiUrl;
	NSDictionary *authHeaders;
	SBJsonParser *parser;
	SBJsonWriter *writer;
	NSInteger operation;
	AsyncRestConnection *connection;
	id <TypeLinkConnectionDelegate> delegate;
}

-(id)initWithApiUrl:(NSString *)apiUrl
		authHeaders:(NSDictionary *)authHeaders
			 parser:(SBJsonParser *)parser
			 writer:(SBJsonWriter *)writer;

@property (nonatomic,assign) NSInteger operation;
@property (nonatomic,retain) NSString *apiUrl;
@property (nonatomic,retain) NSDictionary *authHeaders;
@property (nonatomic,retain) SBJsonParser *parser;
@property (nonatomic,retain) SBJsonWriter *writer;
@property (nonatomic,retain) AsyncRestConnection *connection;
@property (nonatomic,retain) id <TypeLinkConnectionDelegate> delegate;

-(void)registerUser:(User *)user
	   withDelegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)getAccountWithDelegate:(id <TypeLinkConnectionDelegate>)delegate;

- (void)saveAccount:(User *)user
       withDelegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)getFontsWithDelegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)listPagesForUser:(NSString *)user
			   delegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)listPagesSharedToUser:(NSString *)user
					delegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)createPage:(Page *)p
		  forUser:(NSString *)u
		 delegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)getPageForUser:(NSString *)user
			withTitle:(NSString *)title
			 delegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)savePage:(Page *)p
	  withTitle:(NSString *)t
		forUser:(NSString *)u
	   delegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)deletePageForUser:(NSString *)u
			   withTitle:(NSString *)t
				delegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)sharePage:(Page *)p
		 forUser:(NSString *)owner
		  toUser:(NSString *)user
		delegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)unsharePage:(Page *)p
		   forUser:(NSString *)owner
		  fromUser:(NSString *)user
		  delegate:(id <TypeLinkConnectionDelegate>)delegate;

-(void)addAlias:(NSString *)a
		 toPage:(Page *)p
	   delegate:(id <TypeLinkConnectionDelegate>)d;

-(void)removeAlias:(NSString *)a
		  fromPage:(Page *)p
		  delegate:(id <TypeLinkConnectionDelegate>)d;

@end
