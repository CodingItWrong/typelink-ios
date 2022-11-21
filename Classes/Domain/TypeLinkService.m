//
//  TypeLinkService.m
//  TypeLink
//
//  Created by Josh Justice on 10/20/10.
//  Copyright 2010 Josh Justice. All rights reserved.
//

#import "TypeLinkService.h"
#import "JSON.h"
#import	"Page.h"
#import "Settings.h"

@interface TypeLinkService()

-(NSDictionary *)authHeaders;

@end


@implementation TypeLinkService

@synthesize parser;
@synthesize writer;
@synthesize apiUrl;
@synthesize settings;

static TypeLinkService *currentService = nil;
static NSMutableDictionary *authHeaders = nil;

+(TypeLinkService *)currentService {
	return currentService;
}
+(void)setCurrentService:(TypeLinkService *)s {
	currentService = s;
}


-(id)initWithApiUrl:(NSString *)u
		   settings:(Settings *)s
{
	if((self = [super init])) {
		self.apiUrl = u; // retained by accessor
		self.settings = s;
		parser = [[SBJsonParser alloc] init]; // retained by alloc
		writer = [[SBJsonWriter alloc] init]; // retained by alloc
	}
	return self;
}

-(NSDictionary *)authHeaders {
	if( nil == authHeaders ) {
		NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
		NSString *version = [dict objectForKey:@"CFBundleVersion"];
		authHeaders = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				@"application/json",@"Content-Type",
				@"ios",@"TypeLink-App",
				version,@"TypeLink-Version",
				nil];
	}
    
    // always update authString in case it's changed
    NSString *authString = [NSString stringWithFormat:@"%@:%@",
                            settings.username, settings.password, nil];
    [authHeaders setValue:authString forKey:@"Authorization"];
    
	return authHeaders;
}

-(TypeLinkConnection *)registerUser:(User *)user
					   withDelegate:(id)delegate
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn registerUser:user
		  withDelegate:delegate];
	return conn;
}

-(TypeLinkConnection *)getAccountWithDelegate:(id)delegate
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn getAccountWithDelegate:delegate];
	return conn;
}

-(TypeLinkConnection *)saveAccount:(User *)user
                      withDelegate:(id)delegate
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn saveAccount:user withDelegate:delegate];
	return conn;
}

-(TypeLinkConnection *)getFontsWithDelegate:(id)delegate
{
	NSLog(@"getFontsWithDelegate");
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn getFontsWithDelegate:delegate];
	return conn;
}

-(TypeLinkConnection *)listPagesForUser:(NSString *)user
							   delegate:(id)delegate;
{
	TypeLinkConnection *conn =
		[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
									   authHeaders:[self authHeaders]
											parser:parser
											writer:writer];
	[conn listPagesForUser:user
				  delegate:delegate];
	return conn;
}

-(TypeLinkConnection *)listPagesSharedToUser:(NSString *)user
									delegate:(id)delegate;
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn listPagesSharedToUser:user
					   delegate:delegate];
	return conn;
}

-(TypeLinkConnection *)createPage:(Page *)p
						  forUser:(NSString *)u
						 delegate:(id)delegate;
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn createPage:p
			 forUser:u
			delegate:delegate];
	return conn;
}

-(TypeLinkConnection *)getPageForUser:(NSString *)user
							withTitle:(NSString *)title
							 delegate:(id)delegate;
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn getPageForUser:user
			   withTitle:title
				delegate:delegate];
	return conn;
}

-(TypeLinkConnection *)savePage:(Page *)page
		withTitle:(NSString *)title
		 delegate:(id)delegate
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn savePage:page
		 withTitle:title
		   forUser:page.user
		  delegate:delegate];
	return conn;
}
	
-(TypeLinkConnection *)deletePageForUser:(NSString *)u
							   withTitle:(NSString *)t
								delegate:(id)delegate;
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn deletePageForUser:u
				  withTitle:t
				   delegate:delegate];
	return conn;
}

-(TypeLinkConnection *)sharePage:(Page *)p
						  toUser:(NSString *)user
						delegate:(id)delegate
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn sharePage:p
			forUser:settings.username
			 toUser:user
		   delegate:delegate];
	return conn;
}

-(TypeLinkConnection *)unsharePage:(Page *)p
						  fromUser:(NSString *)user
						  delegate:(id)delegate
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn unsharePage:p
			  forUser:settings.username
			 fromUser:user
			 delegate:delegate];
	return conn;
}

-(TypeLinkConnection *)addAlias:(NSString *)a
						 toPage:(Page *)p
					   delegate:(id)d
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn addAlias:a
			toPage:p
		  delegate:d];
	return conn;
}

-(TypeLinkConnection *)removeAlias:(NSString *)a
						  fromPage:(Page *)p
						  delegate:(id)d
{
	TypeLinkConnection *conn =
	[[TypeLinkConnection alloc] initWithApiUrl:apiUrl
								   authHeaders:[self authHeaders]
										parser:parser
										writer:writer];
	[conn removeAlias:a
			 fromPage:p
			 delegate:d];
	return conn;
}

@end
