//
//  SharedPagesViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 11/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SharedPagesViewController.h"
#import "Page.h"
#import "PageViewController.h"
#import "Settings.h"
#import "TypeLinkService.h"

@interface SharedPagesViewController()

-(void)loadPages;
-(void)pushPage:(Page *)p;

@end

@implementation SharedPagesViewController

@synthesize pages;
@synthesize settings;
@synthesize typeLinkConnection;

@synthesize activity;

-(id)initWithSettings:(Settings *)set
{
    self = [self initWithNibName:@"SharedPagesViewController"
                          bundle:[NSBundle mainBundle]];
	if( self )
	{
		self.settings = set;
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Shared to Me";
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
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
	
	self.navigationController.toolbarHidden = NO;
	NSArray *toolbarItems = [NSArray arrayWithObjects:
							 space,activityBtn,nil];
	self.toolbarItems = toolbarItems;
}

- (void)viewWillAppear:(BOOL)animated {
	[self loadPages];
	[super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
		|| interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [pages count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
	Page *p = [pages objectAtIndex:indexPath.row];
	cell.textLabel.text = p.title;
	cell.detailTextLabel.text = p.user;
	if( p.publiclyVisible ) {
		cell.textLabel.textColor = [UIColor colorWithRed:0.0
												   green:0.0
													blue:0.93
												   alpha:1.0]; // #0000EE
	} else {
		cell.textLabel.textColor = [UIColor colorWithRed:0.33
												   green:0.1
													blue:0.55
												   alpha:1.0]; // #551A8B
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
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
	[self pushPage:[pages objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark Business logic methods

-(void)loadPages {
	NSLog(@"loadPages: self = %@", self);
	NSLog(@"user = %@", settings.username);
	[activity startAnimating];
	typeLinkConnection = [[TypeLinkService currentService] listPagesSharedToUser:settings.username
                                                                        delegate:self];
}

- (void)connectionFailed:(TypeLinkConnection *)connection
		  withStatusCode:(NSInteger)statusCode
				 message:(NSString *)message
{
	// security error
	if( statusCode == 403 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:message
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK",nil];
		[alert show];
	}
}

- (void)listSharedConnectionFinished:(TypeLinkConnection *)connection
							withList:(NSMutableArray *)myPages
{
	self.pages = myPages;
	[self.tableView reloadData];
	[activity stopAnimating];
}

- (void)pushPage:(Page *)p {
	PageViewController *pageViewController =
	[[PageViewController alloc] initWithUser:p.user
										page:p.title
									settings:settings];
	[self.navigationController pushViewController:pageViewController animated:YES];
}

- (void)modalDismiss {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end

