//
//  AccountSettingsViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
@class ActivityBarButtonItem;
@class Font;
@class Settings;
@class User;
@class TypeLinkConnection;

@interface AccountSettingsViewController : UIViewController
    <UITableViewDataSource,UITableViewDelegate,ModalDelegate>
{
    Settings *settings;
    User *user;
    
    Font *defaultFont;
    float fontSize;
    
    UITextField *emailField;
    UISwitch *sendEmails;
    UISwitch *lockOnExit;
    IBOutlet UITableView *tableView;
    
    ActivityBarButtonItem *activityItem;
    UIBarButtonItem *saveButton;
    
	__unsafe_unretained id <ModalDelegate> delegate;
	BOOL popover;
    
    TypeLinkConnection *typeLinkConnection;
}

@property (nonatomic,retain) Settings *settings;
@property (nonatomic,retain) User *user;
@property (nonatomic,retain) Font *defaultFont;
@property (nonatomic,assign) float fontSize;

@property (nonatomic,retain) UITextField *emailField;
@property (nonatomic,retain) UISwitch *sendEmails;
@property (nonatomic,retain) UISwitch *lockOnExit;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,retain) ActivityBarButtonItem *activityItem;
@property (nonatomic,retain) UIBarButtonItem *saveButton;
@property (nonatomic,assign) id <ModalDelegate> delegate;
@property (nonatomic,assign) BOOL popover;
@property (nonatomic,retain) TypeLinkConnection *typeLinkConnection;

- (id)initWithSettings:(Settings *)settings
              delegate:(id <ModalDelegate>)delegate
               popover:(BOOL)popover;

- (IBAction)save;
- (IBAction)cancel;

@end
