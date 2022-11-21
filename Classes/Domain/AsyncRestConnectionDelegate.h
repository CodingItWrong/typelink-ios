//
//  AsyncRestConnectionDelegate.h
//  TypeLinkData
//
//  Created by Josh Justice on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AsyncRestConnection;

@protocol AsyncRestConnectionDelegate<NSObject>

- (void) connectionDidFail:(AsyncRestConnection *)theConnection;
- (void) connectionDidFinish:(AsyncRestConnection *)theConnection;

@end
