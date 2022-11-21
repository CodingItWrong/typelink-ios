//
//  EditPageDelegate.h
//  TypeLinkNav
//
//  Created by Josh Justice on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Font;
@class Page;

@protocol ModalDelegate

@optional

-(void)modalDismissAndUpdatePage:(Page *)p;
-(void)modalDismissAndShowRegister;
-(void)modalDismiss;
-(void)updateFont:(Font *)font;
-(void)updateFontSize:(float)size;

@end
