//
//  TableSettingsViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ModalDelegate;
@class Settings;

@interface TableSettingsViewController : UIViewController
	<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
	Settings *settings;
	__unsafe_unretained id <ModalDelegate> delegate;
	BOOL error;
	BOOL popover;
	
	UITextField *usernameField;
	UITextField *passwordField;
	UINavigationBar *navBar;
}

@property (nonatomic,retain) Settings *settings;
@property (nonatomic,assign) id <ModalDelegate> delegate;
@property (nonatomic,assign) BOOL error;
@property (nonatomic,assign) BOOL popover;

@property (nonatomic,retain) IBOutlet UITextField *usernameField;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;
@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;

-(id)initWithSettings:(Settings *)s delegate:(id <ModalDelegate>)d;

-(id)initWithSettings:(Settings *)s
			 delegate:(id <ModalDelegate>)d
				error:(BOOL)error
			  popover:(BOOL)p;

-(IBAction)save;
-(IBAction)cancel;

@end
