//
//  RegisterTableViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;
@class TypeLinkConnection;
@protocol ModalDelegate;

@interface RegisterTableViewController : UIViewController
	<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
	Settings *settings;
	__unsafe_unretained id <ModalDelegate> delegate;
	BOOL popover;
	
	UITextField *usernameField;
	UITextField *emailField;
	UITextField *passwordField;
	UITextField *passwordConfirmField;
	UINavigationBar *navBar;
    TypeLinkConnection *typeLinkConnection;
}

@property (nonatomic,retain) Settings *settings;
@property (nonatomic,assign) id <ModalDelegate> delegate;
@property (nonatomic,assign) BOOL popover;

@property (nonatomic,retain) UITextField *usernameField;
@property (nonatomic,retain) UITextField *emailField;
@property (nonatomic,retain) UITextField *passwordField;
@property (nonatomic,retain) UITextField *passwordConfirmField;
@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) TypeLinkConnection *typeLinkConnection;

-(id)initWithSettings:(Settings *)s
			 delegate:(id <ModalDelegate>)d
			  popover:(BOOL)p;

-(IBAction)doRegister;
-(IBAction)cancel;

@end
