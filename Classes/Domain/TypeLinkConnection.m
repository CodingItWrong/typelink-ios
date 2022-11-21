//
//  TypeLinkConnection.m
//  TypeLinkData
//
//  Created by Josh Justice on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TypeLinkConnection.h"
#import "AsyncRestConnection.h"
#import "AsyncRestConnectionDelegate.h"
#import "Font.h"
#import "Page.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "TypeLinkConnectionDelegate.h"
#import "UrlUtils.h"
#import "User.h"

#define LIST_OP         0
#define CREATE_OP       1
#define GET_OP          2
#define SAVE_OP         3
#define DELETE_OP       4
#define SHARE_OP        5
#define UNSHARE_OP      6
#define LIST_SHARED_OP  7
#define ACCOUNT_OP      8
#define FONTS_OP        9
#define ADD_ALIAS_OP    10
#define REMOVE_ALIAS_OP 11
#define REGISTER_OP		12
#define SAVE_ACCOUNT_OP 13

@interface TypeLinkConnection()

-(NSMutableArray *)pagesFromJson:(NSString *)resultString;
-(User *)userFromJson:(NSString *)resultString;
-(NSArray *)fontsFromJson:(NSString *)resultString;
-(NSString *)urlEncode:(NSString *)string;
-(NSString *)formatErrors:(NSString *)resultString;

@end


@implementation TypeLinkConnection

@synthesize apiUrl;
@synthesize authHeaders;
@synthesize parser;
@synthesize writer;
@synthesize operation;
@synthesize connection;
@synthesize delegate;

-(id)initWithApiUrl:(NSString *)u
		authHeaders:(NSDictionary *)h
			 parser:(SBJsonParser *)p
writer:(SBJsonWriter *)w
{
	if( ( self = [super init] ) ) {
		self.apiUrl = u;
		self.authHeaders = h;
		self.parser = p;
		self.writer = w;
	}
	return self;
}

-(NSString *)urlEncode:(NSString *)string
{
	return [UrlUtils urlEncode:string];
}

-(void)registerUser:(User *)u
	   withDelegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = REGISTER_OP;
	self.delegate = d;
	
	NSString *encodedUser = [self urlEncode:u.login];
	NSString *url = [NSString stringWithFormat:@"%@/%@",
					 apiUrl, encodedUser];
	
	NSString *jsonData = [writer stringWithObject:[u asDict]];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
														method:METHOD_POST
														  body:jsonData
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)getAccountWithDelegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = ACCOUNT_OP;
	self.delegate = d;
	
	NSString *url = [NSString stringWithFormat:@"%@/account",
					 apiUrl];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
													   headers:[self authHeaders]
													  delegate:self];
}

- (void)saveAccount:(User *)user
       withDelegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = SAVE_ACCOUNT_OP;
	self.delegate = d;
	
	// set up query
	NSString *url = [NSString stringWithFormat:@"%@/account",
					 apiUrl];
	
	NSString *jsonData = [writer stringWithObject:[user asDict]];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
														method:METHOD_PUT
														  body:jsonData
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)getFontsWithDelegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = FONTS_OP;
	self.delegate = d;
	
	NSString *url = [NSString stringWithFormat:@"%@/fonts",
					 apiUrl];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)listPagesForUser:(NSString *)user
						   delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = LIST_OP;
	self.delegate = d;
	
	NSString *url = [NSString stringWithFormat:@"%@/%@",
					 apiUrl, user];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)listPagesSharedToUser:(NSString *)user
					delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = LIST_SHARED_OP;
	self.delegate = d;
	
	NSString *url = [NSString stringWithFormat:@"%@/%@/sharedTo",
					 apiUrl, user];
	
	NSLog(@"url = %@", url);
	NSLog(@"auth headers %@", [self authHeaders]);
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)createPage:(Page *)page
		  forUser:(NSString *)user
		 delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = CREATE_OP;
	self.delegate = d;
	
	NSString *encodedTitle = [self urlEncode:page.title];
	NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",
						   apiUrl, user, encodedTitle];
	
	NSString *jsonData = [writer stringWithObject:[page asDict]];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:urlString
														method:METHOD_POST
														  body:jsonData
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)getPageForUser:(NSString *)user
			withTitle:(NSString *)title
			 delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = GET_OP;
	self.delegate = d;
	
	//NSString *encodedTitle = [title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSString *encodedTitle = [self urlEncode:title];
	NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",
						   apiUrl, user, encodedTitle];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:urlString
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)savePage:(Page *)page
	  withTitle:(NSString *)title
		forUser:(NSString *)user
	   delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = SAVE_OP;
	self.delegate = d;
	
	// set up query
	NSString *encodedTitle = [self urlEncode:title];
	NSString *url = [NSString stringWithFormat:@"%@/%@/%@",
					 apiUrl, user, encodedTitle];
	NSString *jsonData = [writer stringWithObject:[page asDict]];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
														method:METHOD_PUT
														  body:jsonData
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)deletePageForUser:(NSString *)user
			   withTitle:(NSString *)title
				delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = DELETE_OP;
	self.delegate = d;
	
	NSString *encodedTitle = [self urlEncode:title];
	NSString *url = [NSString stringWithFormat:@"%@/%@/%@",
					 apiUrl, user, encodedTitle];
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
														method:METHOD_DELETE
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)sharePage:(Page *)p
		 forUser:(NSString *)owner
		  toUser:(NSString *)user
		delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = SHARE_OP;
	self.delegate = d;
	
	NSString *encodedTitle = [self urlEncode:p.title];
	NSString *url = [NSString stringWithFormat:@"%@/%@/%@/sharedTo/%@",
					 apiUrl, owner, encodedTitle, user];
	
	NSLog(@"connecting to %@", url);
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
														method:METHOD_POST
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)unsharePage:(Page *)p
		   forUser:(NSString *)owner
		  fromUser:(NSString *)user
		  delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = UNSHARE_OP;
	self.delegate = d;
	
	NSString *encodedTitle = [self urlEncode:p.title];
	NSString *url = [NSString stringWithFormat:@"%@/%@/%@/sharedTo/%@",
					 apiUrl, owner, encodedTitle, user];
	
	NSLog(@"connecting to %@", url);
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
														method:METHOD_DELETE
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)addAlias:(NSString *)a
		 toPage:(Page *)p
	   delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = ADD_ALIAS_OP;
	self.delegate = d;
	
	NSString *encodedTitle = [self urlEncode:p.title];
	NSString *encodedAlias = [self urlEncode:a];
	NSString *url = [NSString stringWithFormat:@"%@/%@/%@/alias/%@",
					 apiUrl, p.user, encodedTitle, encodedAlias];
	
	NSLog(@"connecting to %@", url);
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
														method:METHOD_POST
													   headers:[self authHeaders]
													  delegate:self];
}

-(void)removeAlias:(NSString *)a
		  fromPage:(Page *)p
		  delegate:(id <TypeLinkConnectionDelegate>)d
{
	self.operation = REMOVE_ALIAS_OP;
	self.delegate = d;
	
	NSString *encodedTitle = [self urlEncode:p.title];
	NSString *encodedAlias = [self urlEncode:a];
	NSString *url = [NSString stringWithFormat:@"%@/%@/%@/alias/%@",
					 apiUrl, p.user, encodedTitle, encodedAlias];
	
	NSLog(@"connecting to %@", url);
	
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
														method:METHOD_DELETE
													   headers:[self authHeaders]
													  delegate:self];
}


-(void)connectionDidFail:(AsyncRestConnection *)connection
{
	[delegate connectionFailed:self
				withStatusCode:0
					   message:nil];
}

-(void)connectionDidFinish:(AsyncRestConnection *)c
{
	NSString *resultString = [[NSString alloc] initWithData:c.receivedData
												   encoding:NSUTF8StringEncoding];
	NSLog(@"result string: %@", resultString);
	User *user = nil;
	Page *page = nil;
	NSMutableArray *pages = nil;
    int responseCode = (int)c.responseCode;
	switch( self.operation ) {
		case REGISTER_OP:
			NSLog(@"register success");
			if( c.responseCode == 201 ) {
				NSLog(@"201");
				user = [self userFromJson:resultString];
				[delegate registerConnectionFinished:self
											withUser:user];
			} else {
				NSLog(@"not 201");
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:[self formatErrors:resultString]];
			}
			break;
		case ACCOUNT_OP:
			if( c.responseCode == 200 ) {
				user = [self userFromJson:resultString];
				[delegate accountConnectionFinished:self
										   withUser:user];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
        case SAVE_ACCOUNT_OP:
			if( c.responseCode == 201 ) {
				user = [self userFromJson:resultString];
				[delegate saveAccountConnectionFinished:self
                                               withUser:user];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case FONTS_OP:
			if( c.responseCode == 200 ) {
				NSArray *fonts = [self fontsFromJson:resultString];
				[delegate fontsConnectionFinished:self
										withFonts:fonts];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case LIST_OP:
			if( c.responseCode == 200 ) {
				pages = [self pagesFromJson:resultString];
				[delegate listConnectionFinished:self
										withList:pages];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case CREATE_OP:
			if( c.responseCode == 201 ) {
				NSMutableDictionary *resultObj =
					[parser objectWithString:resultString];
				page = [Page pageFromDict:resultObj];
				[delegate createConnectionFinished:self
										  withPage:page];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case GET_OP:
			if( c.responseCode == 200 ) {
				NSMutableDictionary *resultObj = [parser objectWithString:resultString];
				page = [Page pageFromDict:resultObj];
				
				[delegate getConnectionFinished:self
									   withPage:page];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case SAVE_OP:
			if( c.responseCode == 201 ) {
				NSMutableDictionary *dict = [parser objectWithString:resultString];
				page = [Page pageFromDict:dict];
				[delegate saveConnectionFinished:self
										withPage:page];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case DELETE_OP:
			if( c.responseCode == 200 ) {
				[delegate deleteConnectionFinished:self];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case SHARE_OP:
			if( c.responseCode == 200 ) {
				[delegate shareConnectionFinished:self];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case UNSHARE_OP:
			if( c.responseCode == 200 ) {
				[delegate unshareConnectionFinished:self];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case LIST_SHARED_OP:
			if( c.responseCode == 200 ) {
				pages = [self pagesFromJson:resultString];
				[delegate listSharedConnectionFinished:self
											  withList:pages];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case ADD_ALIAS_OP:
			if( c.responseCode == 200 ) {
				[delegate addAliasConnectionFinished:self];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		case REMOVE_ALIAS_OP:
			if( c.responseCode == 200 ) {
				[delegate removeAliasConnectionFinished:self];
			} else {
				[delegate connectionFailed:self
							withStatusCode:responseCode
								   message:resultString];
			}
			break;
		default:
			NSLog(@"Connection finished but op type not set - don't know how to respond.");
	}
}

-(NSMutableArray *)pagesFromJson:(NSString *)resultString
{
	NSMutableArray *results =
	[parser objectWithString:resultString];
	
	// convert to objects
	NSMutableArray *pages = [NSMutableArray arrayWithCapacity:[results count]];
	NSEnumerator *e = [results objectEnumerator];
	NSMutableDictionary *resultObj;
	while( ( resultObj = [e nextObject] ) ) {
		[pages addObject:[Page pageFromDict:resultObj]];
	}
	
	return pages;
}

-(User *)userFromJson:(NSString *)resultString
{
	NSMutableDictionary *dict = [parser objectWithString:resultString];
	User *user = [User userFromDict:dict];
	return user;
}

-(NSArray *)fontsFromJson:(NSString *)resultString
{
	NSMutableArray *array = [parser objectWithString:resultString];
	NSMutableArray *fonts = [NSMutableArray arrayWithCapacity:[array count]];
	NSEnumerator *e = [array objectEnumerator];
	NSMutableDictionary *dict;
	while( ( dict = [e nextObject] ) ) {
		[fonts addObject:[Font fontFromDict:dict]];
	}
	return fonts;
}

-(NSString *)formatErrors:(NSString *)resultString
{
	NSArray *errors = [parser objectWithString:resultString];
	NSString *fullString = @"";
	NSString *errorString;
	NSEnumerator *enumerator = [errors objectEnumerator];
	while( ( errorString = [enumerator nextObject] ) ) {
		fullString = [fullString stringByAppendingFormat:@"%@\n", errorString ];
	}
	return fullString;
}

@end
