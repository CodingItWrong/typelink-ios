//
//  RootViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 10/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ModalDelegate.h"
#import "TypeLinkConnection.h"
@class TypeLinkService;
@class TypeLinkConnection;
@class Settings;

@interface RootViewController : UITableViewController
	<ModalDelegate,UIPopoverControllerDelegate,NSFetchedResultsControllerDelegate>
{

	Settings *settings;
	NSMutableArray *pages;
	
	UIViewController *modal;
	UIPopoverController *popover;
	UIActivityIndicatorView *activity;
	BOOL viewShown;
	BOOL showSecurityModalOnAppear;
	BOOL showRegisterModalOnAppear;
    TypeLinkConnection *typeLinkConnection;
	
	// TODO: make private again
    NSManagedObjectContext *managedObjectContext_;
	
@private
    NSFetchedResultsController *fetchedResultsController_;
}

@property (nonatomic,retain) NSDictionary *config;
@property (nonatomic,retain) Settings *settings;
@property (nonatomic,retain) NSMutableArray *pages;

@property (nonatomic,retain) UIViewController *modal;
@property (nonatomic,retain) UIPopoverController *popover;
@property (nonatomic,retain) UIActivityIndicatorView *activity;
@property (nonatomic,assign) BOOL viewShown;
@property (nonatomic,assign) BOOL showSecurityModalOnAppear;
@property (nonatomic,assign) BOOL showRegisterModalOnAppear;
@property (nonatomic,retain) TypeLinkConnection *typeLinkConnection;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(void)setUpToolbar;

@end
