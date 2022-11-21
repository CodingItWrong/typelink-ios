//
//  EditPageViewController.h
//  TypeLinkNav
//
//  Created by Josh Justice on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ActivityBarButtonItem;
@class Page;
@class TypeLinkConnection;
@protocol ModalDelegate;

@interface EditPageViewController : UIViewController
	<UIActionSheetDelegate>
{
	IBOutlet UITextView *textView;
    IBOutlet NSLayoutConstraint *textViewBottomConstraint;
	
	IBOutlet UIBarButtonItem *saveBtn;
	UIBarButtonItem *enabledSaveBtn;
	IBOutlet UIBarButtonItem *closeBtn;
	ActivityBarButtonItem *activityItem;
	UIActivityIndicatorView *activity;
    
    TypeLinkConnection *typeLinkConnection;
	
	Page *page;
	NSString *text;
	NSString *savedText;
	__unsafe_unretained id <ModalDelegate> delegate;
	
	CGRect originalTextViewFrame;
	CGFloat keyboardHeight;
	BOOL anyChangesSaved;
	BOOL changed;
	BOOL closeAfterSave;
    BOOL firstLayout;
}

@property (nonatomic,retain) IBOutlet UITextView *textView;

@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *closeBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *saveBtn;
@property (nonatomic,retain) UIBarButtonItem *enabledSaveBtn;
@property (nonatomic,retain) ActivityBarButtonItem *activityItem;

@property (nonatomic,retain) TypeLinkConnection *typeLinkConnection;
@property (nonatomic,retain) Page *page;
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *savedText;
@property (nonatomic,assign) id <ModalDelegate> delegate;

@property (nonatomic,assign) CGRect originalTextViewFrame;
@property (nonatomic,assign) CGFloat keyboardHeight;
@property (nonatomic,assign) BOOL anyChangesSaved;
@property (nonatomic,assign) BOOL changed;
@property (nonatomic,assign) BOOL closeAfterSave;
@property (nonatomic,assign) BOOL firstLayout;

-(id)initWithPage:(Page *)p
		 delegate:(id <ModalDelegate>)d;

-(id)initWithPage:(Page *)p
			 text:(NSString *)t
		 delegate:(id <ModalDelegate>)d;

-(IBAction)save;
-(IBAction)close;

@end
