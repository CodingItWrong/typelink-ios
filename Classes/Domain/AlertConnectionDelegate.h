//
//  AlertConnectionDelegate.h
//  TypeLinkData
//
//  Created by Josh Justice on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AlertConnection;

@protocol AlertConnectionDelegate <NSObject>

@optional

- (void)connectionFailed:(AlertConnection *)conn
          withStatusCode:(int)code
                 message:(NSString *)msg;

- (void)alertConnectionFinished:(AlertConnection *)conn
                     withAlerts:(NSArray *)alerts;

@end
