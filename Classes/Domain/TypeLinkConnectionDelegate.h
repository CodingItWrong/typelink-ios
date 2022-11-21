//
//  TypeLinkConnectionDelegate.h
//  TypeLinkData
//
//  Created by Josh Justice on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TypeLinkConnection;
@class Page;
@class User;

@protocol TypeLinkConnectionDelegate <NSObject>

- (void)connectionFailed:(TypeLinkConnection *)conn
          withStatusCode:(int)code
                 message:(NSString *)msg;

@optional

- (void)registerConnectionFinished:(TypeLinkConnection *)conn
                          withUser:(User *)user;

- (void)accountConnectionFinished:(TypeLinkConnection *)conn
                         withUser:(User *)user;

- (void)saveAccountConnectionFinished:(TypeLinkConnection *)conn
                             withUser:(User *)user;

- (void)fontsConnectionFinished:(TypeLinkConnection *)conn
                      withFonts:(NSArray *)fonts;

- (void)listConnectionFinished:(TypeLinkConnection *)conn
                      withList:(NSArray *)pages;

- (void)createConnectionFinished:(TypeLinkConnection *)conn
                        withPage:(Page *)page;

- (void)getConnectionFinished:(TypeLinkConnection *)conn
                     withPage:(Page *)page;

- (void)saveConnectionFinished:(TypeLinkConnection *)conn
                      withPage:(Page *)page;

- (void)deleteConnectionFinished:(TypeLinkConnection *)conn;

- (void)shareConnectionFinished:(TypeLinkConnection *)conn;

- (void)unshareConnectionFinished:(TypeLinkConnection *)conn;

- (void)listSharedConnectionFinished:(TypeLinkConnection *)conn
                            withList:(NSArray *)pages;

- (void)addAliasConnectionFinished:(TypeLinkConnection *)conn;

- (void)removeAliasConnectionFinished:(TypeLinkConnection *)conn;

@end
