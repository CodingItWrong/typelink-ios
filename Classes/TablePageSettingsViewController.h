//
//  TablePageSettingsViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 11/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
@class Page;
@class ActivityBarButtonItem;
@class TypeLinkConnection;

@interface TablePageSettingsViewController : UIViewController
	<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UITextFieldDelegate,ModalDelegate>
{
	IBOutlet UITableView *tableView;
	UITextField *titleField;
	UISwitch *publiclyVisible;
	UIBarButtonItem *saveButton;
    ActivityBarButtonItem *activityItem;
	UIAlertView *alert;
	
    TypeLinkConnection *typeLinkConnection;
    
	NSString *oldTitle;
	NSString *newTitle;
	NSString *user;
	Page *page;
	__unsafe_unretained id <ModalDelegate> delegate;
	BOOL popover;
	
//	UITextField *shareToField;
    NSString *shareToAdd;
	NSString *shareToDelete;
//	UITextField *aliasField;
    NSString *aliasToAdd;
	NSString *aliasToDelete;
}

@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,retain) UITextField *titleField;
@property (nonatomic,retain) UISwitch *publiclyVisible;
@property (nonatomic,retain) UIBarButtonItem *saveButton;
@property (nonatomic,retain) UIAlertView *alert;

@property (nonatomic,retain) ActivityBarButtonItem *activityItem;

@property (nonatomic,retain) NSString *prevTitle;
@property (nonatomic,retain) NSString *nextTitle;
@property (nonatomic,retain) NSString *user;
@property (nonatomic,retain) Page *page;
@property (nonatomic,assign) id <ModalDelegate> delegate;
@property (nonatomic,assign) BOOL popover;

@property (nonatomic,retain) TypeLinkConnection *typeLinkConnection;

//@property (nonatomic,retain) UITextField *shareToField;
@property (nonatomic,retain) NSString *shareToAdd;
@property (nonatomic,retain) NSString *shareToDelete;
@property (nonatomic,retain) UITextField *aliasField;
@property (nonatomic,retain) NSString *aliasToAdd;
@property (nonatomic,retain) NSString *aliasToDelete;

-(IBAction)cancel;
-(IBAction)save;

-(id)initWithUser:(NSString *)u
		 pageName:(NSString *)pn
		 delegate:(id <ModalDelegate>)delegate
		  popover:(BOOL)p;

-(id)initWithPage:(Page *)page
		 delegate:(id <ModalDelegate>)delegate
		  popover:(BOOL)p;

-(IBAction)textFieldReturn:(id)sender;

@end
