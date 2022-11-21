//
//  RootViewController.m
//  TypeLinkNav
//
//  Created by Josh Justice on 10/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"

#import "AboutViewController.h"
#import "AccountSettingsViewController.h"
#import "Page.h"
#import "PageViewController.h"
#import "RegisterTableViewController.h"
#import "Settings.h"
#import "SharedPagesViewController.h"
#import "TablePageSettingsViewController.h"
#import "TableSettingsViewController.h"
#import "TypeLinkConnection.h"
#import "TypeLinkService.h"

#define MAIN_SECTION     0
#define MY_PAGES_SECTION 1

#define ABOUT_ROW       0
#define ACCOUNT_ROW     1
#define SETTINGS_ROW    2
#define HELP_ROW        3
#define SHARED_ROW      4

@interface RootViewController()

-(void)loadPages;
-(void)pushPage:(Page *)p;
-(void)showAbout;
-(void)showAccount;
-(void)showAccountWithError:(BOOL)error;
-(void)showSettings;
-(void)showShared;

@end


@implementation RootViewController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;

@synthesize config;
@synthesize pages;
@synthesize settings;
@synthesize typeLinkConnection;

@synthesize modal;
@synthesize popover;
@synthesize activity;
@synthesize viewShown;
@synthesize showSecurityModalOnAppear;
@synthesize showRegisterModalOnAppear;

#pragma mark -
#pragma mark View setup 

-(void)setUpToolbar {
	// set up buttons
	UIBarButtonItem *homeBtn =
	[[UIBarButtonItem alloc] initWithTitle:@"Home"
									 style:UIBarButtonItemStylePlain
									target:self
									action:@selector(goToHome)];
	/*
	UIBarButtonItem *settingsBtn =
	[[UIBarButtonItem alloc] initWithTitle:@"Account"
									 style:UIBarButtonItemStyleBordered
									target:self
									action:@selector(showSettings)];	
	UIBarButtonItem *newBtn =
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
												  target:self
												  action:@selector(newPage)];
	 */
	UIBarButtonItem *space =
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
												  target:nil
												  action:nil];
	
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);  
	UIActivityIndicatorView *myActivity = 
		[[UIActivityIndicatorView alloc] initWithFrame:frame];
	[myActivity sizeToFit];
	myActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);  
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    } else {
        [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
	self.activity = myActivity;
	UIBarButtonItem *activityBtn = [[UIBarButtonItem alloc] initWithCustomView:activity];
	
	self.navigationItem.rightBarButtonItem = homeBtn;
	self.navigationController.toolbarHidden = NO;
//	NSArray *toolbarItems = [NSArray arrayWithObjects:
//							 settingsBtn,space,activityBtn,newBtn,nil];
	NSArray *toolbarItems = [NSArray arrayWithObjects:
							 space,activityBtn,nil];
	self.toolbarItems = toolbarItems;
}

#pragma mark -
#pragma mark Business logic methods

-(void)loadPages {
    [self loadPagesFirstTime:NO];
}

-(void)loadPagesFirstTime:(BOOL)firstTime {
    NSLog(@"username = '%@'", settings.username);
    if( [settings.username isEqualToString:@""] ) {
        if( !firstTime && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self showAccountWithError:YES];
        } else {
            showSecurityModalOnAppear = YES;
        }
    } else {
        NSLog(@"loadPages: self = %@", self);
        [activity startAnimating];
        typeLinkConnection = [[TypeLinkService currentService] listPagesForUser:settings.username
                                                                       delegate:self];
    }
}

- (void)connectionFailed:(TypeLinkConnection *)connection
		  withStatusCode:(NSInteger)statusCode
				 message:(NSString *)message
{
	[activity stopAnimating];
	
	// security error
	if( statusCode == 403 ) {
		if( self.viewShown ) {
			NSLog(@"showing security modal without setting the flag");
			[self showAccountWithError:YES];
		} else {
			NSLog(@"setting security modal to appear");
			self.showSecurityModalOnAppear = YES;
		}
	// other error
	} else {
		if( statusCode == 0 ) {
			message = @"Could not connect to TypeLink server. Please make sure you're connected to the internet and try again.";
		} else if( [[message substringToIndex:6] isEqualToString:@"<html>"] ) {
			message = @"A server error occurred. Please try again.";
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:message
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK",nil];
		[alert show];
	}
}

- (void)listConnectionFinished:(TypeLinkConnection *)connection
					  withList:(NSMutableArray *)myPages
{
	self.pages = myPages;
	[self.tableView reloadData];
	[activity stopAnimating];
}

- (void)pushPage:(Page *)p {
	PageViewController *pageViewController =
	[[PageViewController alloc] initWithUser:settings.username
										page:p.title
									settings:settings];
	[self.navigationController pushViewController:pageViewController animated:YES];
}


#pragma mark -
#pragma mark Button handlers

-(void)showAbout {
	AboutViewController *c = [[AboutViewController alloc] initWithNibName:@"AboutViewController"
																   bundle:[NSBundle mainBundle]];
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if( [popover isPopoverVisible] ) {
			[popover dismissPopoverAnimated:YES];
		}
        c.preferredContentSize = CGSizeMake(320.0f, 360.0f);
		UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:c];
		NSUInteger indexArr[] = {MAIN_SECTION,ABOUT_ROW};
		[p presentPopoverFromRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2]]
						   inView:self.tableView
		 permittedArrowDirections:UIPopoverArrowDirectionAny
						 animated:YES];
		self.popover = p;
	} else {
		[self.navigationController pushViewController:c
											 animated:YES];
	}
}

-(void)showAccount {
	[self showAccountWithError:NO];
}

-(void)showAccountWithError:(BOOL)e {
	
	BOOL isPopover = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	TableSettingsViewController *c =
	[[TableSettingsViewController alloc] initWithSettings:settings
												 delegate:self
													error:e
												  popover:isPopover];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:c];

	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if( [popover isPopoverVisible] ) {
			[popover dismissPopoverAnimated:YES];
		}
		c.preferredContentSize = CGSizeMake(300.0f, 240.0f);
		UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:nc];
        p.delegate = self;
		NSUInteger indexArr[] = {MAIN_SECTION,ACCOUNT_ROW};
		[p presentPopoverFromRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2]]
						   inView:self.tableView
		 permittedArrowDirections:UIPopoverArrowDirectionAny
						 animated:YES];
		self.popover = p;
	} else {
        [self presentViewController:nc animated:YES completion:nil];
		self.modal = c;
	}
}

-(void)showSettings {
	
	BOOL isPopover = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	AccountSettingsViewController *c =
	[[AccountSettingsViewController alloc] initWithSettings:settings
												 delegate:self
												  popover:isPopover];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:c];
    
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if( [popover isPopoverVisible] ) {
			[popover dismissPopoverAnimated:YES];
		}
		nc.preferredContentSize = CGSizeMake(300.0f, 335.0f);
		c.preferredContentSize = CGSizeMake(300.0f, 335.0f);
		UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:nc];
		NSUInteger indexArr[] = {MAIN_SECTION,SETTINGS_ROW};
		[p presentPopoverFromRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2]]
						   inView:self.tableView
		 permittedArrowDirections:UIPopoverArrowDirectionAny
						 animated:YES];
		self.popover = p;
	} else {
        [self presentViewController:nc animated:YES completion:nil];
		self.modal = nc;
	}
}

-(void)showRegister {
	BOOL isPopover = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	RegisterTableViewController *c =
	[[RegisterTableViewController alloc] initWithSettings:settings
												 delegate:self
												  popover:isPopover];
	
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:c];
    
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if( [popover isPopoverVisible] ) {
			[popover dismissPopoverAnimated:YES];
		}
		c.preferredContentSize = CGSizeMake(300.0f, 240.0f);
		UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:nc];
		NSUInteger indexArr[] = {MAIN_SECTION,ACCOUNT_ROW};
		[p presentPopoverFromRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2]]
						   inView:self.tableView
		 permittedArrowDirections:UIPopoverArrowDirectionAny
						 animated:YES];
		self.popover = p;
	} else {
        [self presentViewController:nc animated:YES completion:nil];
		self.modal = c;
	}
}

-(void)showShared {
	SharedPagesViewController *c =
	[[SharedPagesViewController alloc] initWithSettings:settings];
	[self.navigationController pushViewController:c
										 animated:YES];
}

- (void)goToHome {
	PageViewController *pageViewController =
	[[PageViewController alloc] initWithUser:settings.username
										page:@"Home"
									settings:settings];
	[self.navigationController pushViewController:pageViewController
										 animated:YES];
}

#pragma mark -
#pragma mark Modal callbacks

- (void)modalDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
	if( self.popover ) {
		if( [popover isPopoverVisible] ) {
			[popover dismissPopoverAnimated:YES];
		}
		[self loadPages]; // not called by viewWillAppear on iPad
	}
}

- (void)modalDismissAndUpdatePage:(Page *)p {
	[self modalDismiss];
}

- (void)modalDismissAndShowRegister {
	NSLog(@"modalDismissAndShowRegister");
    [self dismissViewControllerAnimated:YES completion:nil];
	if( self.popover ) {
		if( [popover isPopoverVisible] ) {
			[popover dismissPopoverAnimated:YES];
		}
		[self showRegister];
		// do not reload pages
	} else {
		self.showRegisterModalOnAppear = YES;
	}
}

#pragma mark -
#pragma mark Popover delegate methods

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    [self loadPages];
    return YES;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	NSLog(@"RootViewController viewDidLoad");
    [super viewDidLoad];
	
	self.title = @"My Pages";
	
	// load page data
	//[self loadPages];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	[self loadPagesFirstTime:YES];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.viewShown = YES;
	
	// TODO: this needs to not be here - not reliable
	NSLog(@"checking whether to show security modal");
	if( self.showRegisterModalOnAppear ) {
		self.showRegisterModalOnAppear = NO;
		self.showSecurityModalOnAppear = NO;
		[self showRegister];
	} else if( self.showSecurityModalOnAppear ) {
		NSLog(@"Showing security modal");
		self.showSecurityModalOnAppear = NO;
		if( [settings.username isEqualToString:@""] ) {
			[self showAccountWithError:NO];
		} else {
			[self showAccountWithError:YES];
		}
	}	
}

/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
- (void)viewDidDisappear:(BOOL)animated {
	self.viewShown = NO;
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
		|| interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch( section ) {
		case MAIN_SECTION:     return 5;
		case MY_PAGES_SECTION: return [pages count];
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch( section ) {
		case MAIN_SECTION:
			return nil;
			break;
		case MY_PAGES_SECTION:
			return @"My Pages";
			break;
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	static NSString *DetailCellIdentifier = @"DetailCell";
	
	UITableViewCell *cell;
	if( MAIN_SECTION == indexPath.section && ACCOUNT_ROW == indexPath.row ) {
		cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DetailCellIdentifier];
		}
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
	}
	
	switch( indexPath.section ) {
		case MAIN_SECTION:
			cell.textLabel.textColor = [UIColor blackColor];
			switch( indexPath.row ) {
				case ABOUT_ROW:
					cell.textLabel.text = @"About TypeLink";
					if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
						cell.accessoryType = UITableViewCellAccessoryNone;
					} else {
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					}
					break;
				case ACCOUNT_ROW:
					cell.textLabel.text = @"Account";
					if( settings.username ) {
						cell.detailTextLabel.text = settings.username;
					} else {
						cell.detailTextLabel.text = @"";
					}
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
                case SETTINGS_ROW:
					cell.textLabel.text = @"Settings";
					cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
				case HELP_ROW:
					cell.textLabel.text = @"Help";
					cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case SHARED_ROW:
					cell.textLabel.text = @"Pages Shared to Me";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
			}
			break;
		case MY_PAGES_SECTION:
			NSLog(@" ");
			Page *p = [pages objectAtIndex:indexPath.row];
			cell.textLabel.text = p.title;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			if( p.publiclyVisible ) {
				cell.textLabel.textColor = [UIColor colorWithRed:0.0
														   green:0.0
															blue:0.93
														   alpha:1.0]; // #0000EE
			} else if( p.shared ) {
				cell.textLabel.textColor = [UIColor colorWithRed:0.33
														   green:0.1
															blue:0.55
														   alpha:1.0]; // #551A8B
			} else {
				cell.textLabel.textColor = [UIColor colorWithRed:0.0
														   green:0.6
															blue:0.0
														   alpha:1.0]; // #009900
			}
			break;
	}
	
	return cell;
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	switch( indexPath.section ) {
		case MAIN_SECTION:
			switch( indexPath.row ) {
				case ABOUT_ROW:   [self showAbout]; break;
				case ACCOUNT_ROW: [self showAccount]; break;
                case SETTINGS_ROW: [self showSettings]; break;
				case SHARED_ROW:  [self showShared]; break;
				case HELP_ROW:
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://typelink.net/help/Home"]];
					break;
			}
			break;
		case MY_PAGES_SECTION:
			[self pushPage:[pages objectAtIndex:indexPath.row]];
			break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end

