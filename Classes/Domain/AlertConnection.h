//
//  AlertConnection.h
//  TypeLinkData
//
//  Created by Josh Justice on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncRestConnectionDelegate.h"
@class SBJsonParser;
@protocol AlertConnectionDelegate;

@interface AlertConnection : NSObject
	<AsyncRestConnectionDelegate>
{
	NSString *apiUrl;
	SBJsonParser *parser;
	AsyncRestConnection *connection;
	__unsafe_unretained id<AlertConnectionDelegate> delegate;
}

@property (nonatomic,retain) NSString *apiUrl;
@property (nonatomic,retain) SBJsonParser *parser;
@property (nonatomic,retain) AsyncRestConnection *connection;
@property (nonatomic,assign) id<AlertConnectionDelegate> delegate;

-(id)initWithApiUrl:(NSString *)apiUrl
			 parser:(SBJsonParser *)parser;

-(void)getAlertsWithDelegate:(id<AlertConnectionDelegate>)delegate;

@end
