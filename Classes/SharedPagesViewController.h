//
//  SharedPagesViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 11/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
@class Settings;
@class TypeLinkService;
@class TypeLinkConnection;

@interface SharedPagesViewController : UITableViewController<ModalDelegate> {
	Settings *settings;
	NSMutableArray *pages;
	
	UIActivityIndicatorView *activity;
    TypeLinkConnection *typeLinkConnection;
}

@property (nonatomic,retain) Settings *settings;
@property (nonatomic,retain) NSMutableArray *pages;
@property (nonatomic,retain) TypeLinkConnection *typeLinkConnection;

@property (nonatomic,retain) UIActivityIndicatorView *activity;

-(id)initWithSettings:(Settings *)settings;

@end
