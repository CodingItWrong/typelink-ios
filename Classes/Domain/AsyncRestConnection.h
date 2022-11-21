//
//  AsyncRestConnection.h
//  TypeLinkData
//
//  Created by Josh Justice on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncRestConnectionDelegate.h"

#define METHOD_GET @"GET"
#define METHOD_PUT @"PUT"
#define METHOD_POST @"POST"
#define METHOD_DELETE @"DELETE"

@class AsyncRestConnectionDelegate;

@interface AsyncRestConnection : NSObject {
	__unsafe_unretained id<AsyncRestConnectionDelegate> delegate;
	NSInteger responseCode;
	NSMutableData *receivedData;
	NSURLConnection *connection;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSInteger responseCode;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;

-(id) initWithURL:(NSString *)url
		 delegate:(id<AsyncRestConnectionDelegate>)delegate;

-(id) initWithURL:(NSString *)url
		  headers:(NSDictionary *)headers
		 delegate:(id<AsyncRestConnectionDelegate>)delegate;

-(id) initWithURL:(NSString *)url
		   method:(NSString *)method
		  headers:(NSDictionary *)headers
		 delegate:(id<AsyncRestConnectionDelegate>)delegate;

- (id) initWithURL:(NSString *)url
			method:(NSString *)method
			  body:(NSString *)body
		   headers:(NSDictionary *)headers
		  delegate:(id<AsyncRestConnectionDelegate>)delegate;


@end
