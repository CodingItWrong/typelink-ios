//
//  AlertService.h
//  TypeLinkData
//
//  Created by Josh Justice on 10/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AlertConnection;
@class SBJsonParser;

@interface AlertService : NSObject {
	NSString *apiUrl;
	SBJsonParser *parser;
}

@property (nonatomic,retain) NSString *apiUrl;
@property (nonatomic,retain) SBJsonParser *parser;

-(id)initWithApiUrl:(NSString *)apiUrl;

-(AlertConnection *)getAlertsWithDelegate:(id)delegate;

@end
