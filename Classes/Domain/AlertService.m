//
//  AlertService.m
//  TypeLinkData
//
//  Created by Josh Justice on 10/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlertService.h"
#import "AlertConnection.h"
#import "SBJsonParser.h"

@implementation AlertService

@synthesize apiUrl;
@synthesize parser;

-(id)initWithApiUrl:(NSString *)u {
	if( self = [super init] ) {
		self.apiUrl = u;
		parser = [[SBJsonParser alloc] init]; // retained by alloc
	}
	return self;
}

-(AlertConnection *)getAlertsWithDelegate:(id)delegate {
	AlertConnection *conn =
	[[AlertConnection alloc] initWithApiUrl:apiUrl
									 parser:parser];
	[conn getAlertsWithDelegate:delegate];
	return conn;
}

@end
