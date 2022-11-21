//
//  AlertConnection.m
//  TypeLinkData
//
//  Created by Josh Justice on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlertConnection.h"
#import "SBJsonParser.h"
#import "AsyncRestConnection.h"
#import "AlertConnectionDelegate.h"

@implementation AlertConnection

@synthesize apiUrl;
@synthesize parser;
@synthesize connection;
@synthesize delegate;

-(id)initWithApiUrl:(NSString *)u
			 parser:(SBJsonParser *)p
{
	if( ( self = [super init] ) ) {
		self.apiUrl = u;
		self.parser = p;
	}
	return self;
}

-(void)getAlertsWithDelegate:(id<AlertConnectionDelegate>)d
{
	self.delegate = d;
	NSString *url = [NSString stringWithFormat:@"%@/alerts", apiUrl];
	self.connection = [[AsyncRestConnection alloc] initWithURL:url
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
	if( c.responseCode == 200 ) {
		NSArray *alerts = [parser objectWithString:resultString];
		
		[delegate alertConnectionFinished:self
							   withAlerts:alerts];
	} else {
		[delegate connectionFailed:self
					withStatusCode:(int)c.responseCode
						   message:resultString];
	}
}


@end
