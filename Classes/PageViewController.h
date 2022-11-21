//
//  PageViewController.h
//  TypeLinkNav
//
//  Created by Josh Justice on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ModalDelegate.h"
@class Page;
@class Settings;
@class TypeLinkService;
@class TypeLinkConnection;
@class User;
@class ProgressViewController;

@interface PageViewController : UIViewController
	<ModalDelegate,UIWebViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
	IBOutlet UIWebView *webView;
	NSInteger webViewScroll;
	UIViewController *modal;
	UIBarButtonItem *editBtn;
	UIBarButtonItem	*settingsBtn;
	UIBarButtonItem *shareBtn;
	UIBarButtonItem *deleteBtn;
	UIBarButtonItem *newBtn;
	UIBarButtonItem *activity;
	UIPopoverController *popover;
	ProgressViewController *progress;
    TypeLinkConnection *typeLinkConneciton;
	
	NSString *user;
	Page *page;
	NSString *pageTitle;
	BOOL editOnLoad;
	NSString *editingText;
	Settings *settings;
}

@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,assign) NSInteger webViewScroll;
@property (nonatomic,retain) IBOutlet UIViewController *modal;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *editBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *settingsBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *shareBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *deleteBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *addBtn;
@property (nonatomic,retain) UIBarButtonItem *activity;
@property (nonatomic,retain) UIPopoverController *popover;
@property (nonatomic,retain) ProgressViewController *progress;
@property (nonatomic,retain) TypeLinkConnection *typeLinkConnection;

@property (nonatomic,retain) NSString *user;
@property (nonatomic,retain) Page *page;
@property (nonatomic,retain) NSString *pageTitle;
@property (nonatomic,assign) BOOL editOnLoad;
@property (nonatomic,retain) NSString *editingText;
@property (nonatomic,retain) Settings *settings;

-(id)initWithUser:(NSString *)user
			 page:(NSString *)page
		 settings:(Settings *)settings;

@end
