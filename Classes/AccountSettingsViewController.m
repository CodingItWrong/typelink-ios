//
//  AccountSettingsViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "ActivityBarButtonItem.h"
#import "Font.h"
#import "FontChooserViewController.h"
#import "FontSizeChooserViewController.h"
#import "ModalDelegate.h"
#import "Settings.h"
#import "TextTableViewCell.h"
#import "TypeLinkService.h"
#import "User.h"

#define NUM_SECTIONS            3

#define GENERAL_SECTION_NUM     0
#define GENERAL_SECTION_TITLE   @"General"
#define GENERAL_SECTION_ROWS    3

#define LOCK_ROW                0
#define EMAIL_ROW               1
#define SEND_EMAILS_ROW         2

#define DISPLAY_SECTION_NUM     1
#define DISPLAY_SECTION_TITLE   @"Display"
#define DISPLAY_SECTION_ROWS    2

#define DEFAULT_FONT_ROW        0
#define FONT_SIZE_ROW           1

@implementation AccountSettingsViewController

@synthesize settings;
@synthesize user;
@synthesize defaultFont;
@synthesize fontSize;

@synthesize emailField;
@synthesize sendEmails;
@synthesize lockOnExit;
@synthesize tableView;
@synthesize activityItem;
@synthesize saveButton;
@synthesize delegate;
@synthesize popover;
@synthesize typeLinkConnection;

- (id)initWithSettings:(Settings *)s
              delegate:(id <ModalDelegate>)d
               popover:(BOOL)p;
{
    self = [self initWithNibName:@"AccountSettingsViewController"
                          bundle:[NSBundle mainBundle]];
    if (self) {
        self.settings = s;
        self.delegate = d;
        self.popover = p;
        
        if( nil == [User currentUser] ) {
            NSLog(@"getting user for first time");
            typeLinkConnection = [[TypeLinkService currentService] getAccountWithDelegate:self];
        } else {
            NSLog(@"already have user");
            self.user = [User currentUser];
        }
        
        self.defaultFont = self.user.defaultFont;
        self.fontSize = [self.settings.fontSize floatValue];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Settings";
    
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                     target:self
                                                                     action:@selector(save)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    self.activityItem = [[ActivityBarButtonItem alloc] initAsPopover:popover];
//	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);  
//	UIActivityIndicatorView *myActivity = 
//	[[UIActivityIndicatorView alloc] initWithFrame:frame];
//	[myActivity sizeToFit];
//	myActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);  
//    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//    } else {
//        [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
//    }
//    [myActivity startAnimating];
//	UIBarButtonItem *myActivityItem = [[UIBarButtonItem alloc] initWithCustomView:myActivity];
//	self.activityItem = myActivityItem;
//	[myActivityItem release];
//	[myActivity release];

	if( !popover ) {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                       target:self
                                                       action:@selector(cancel)];
	}
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch( section ) {
        case GENERAL_SECTION_NUM: return GENERAL_SECTION_ROWS; break;
        case DISPLAY_SECTION_NUM: return DISPLAY_SECTION_ROWS; break;
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch( section ) {
        case GENERAL_SECTION_NUM: return GENERAL_SECTION_TITLE; break;
        case DISPLAY_SECTION_NUM: return DISPLAY_SECTION_TITLE; break;
        default: return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	static NSString *TextCellIdentifier = @"TextCell";
	static NSString *DetailCellIdentifier = @"MyDetailCell";
    
	UITableViewCell *cell;
	
    if( GENERAL_SECTION_NUM == indexPath.section && EMAIL_ROW == indexPath.row ) {
        cell = [tv dequeueReusableCellWithIdentifier:TextCellIdentifier];
        if( cell == nil ) {
            cell = [[TextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier];
        }
    } else if( DISPLAY_SECTION_NUM == indexPath.section ) {
        cell = [tv dequeueReusableCellWithIdentifier:DetailCellIdentifier];
        if( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DetailCellIdentifier];
        }
    } else {
        cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    
    UISwitch *mySwitch;
    switch( indexPath.section ) {
        case GENERAL_SECTION_NUM:
            switch( indexPath.row ) {
                case EMAIL_ROW:
                    cell.textLabel.text = @"Email";
                    self.emailField = ((TextTableViewCell *)cell)._textField;
                    emailField.text = user.email;
                    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
                    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case SEND_EMAILS_ROW:
                    cell.textLabel.text = @"Send Emails";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [cell addSubview:mySwitch];
                    cell.accessoryView = mySwitch;
                    self.sendEmails = mySwitch;
                    self.sendEmails.on = user.sendEmails;
                    break;
                case LOCK_ROW:
                    cell.textLabel.text = @"Lock App on Exit";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [cell addSubview:mySwitch];
                    cell.accessoryView = mySwitch;
                    self.lockOnExit = mySwitch;
                    self.lockOnExit.on = [settings.lock boolValue];
                    break;
            }
            break;
        case DISPLAY_SECTION_NUM:
            switch( indexPath.row ) {
                case DEFAULT_FONT_ROW:
                    cell.textLabel.text = @"Default Font";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    if( nil != defaultFont ) {
                        NSLog(@"font: %@", defaultFont.name);
                        cell.detailTextLabel.text = defaultFont.name;
                        UIFont *myFont = [UIFont fontWithName:defaultFont.iOSCode size:16.0f];
                        if( myFont ) {
                            cell.detailTextLabel.font = myFont;
                        }
                    }
                    break;
                case FONT_SIZE_ROW:
                    cell.textLabel.text = @"Font Size";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    int sizePct = 100.0 * fontSize;
                    cell.detailTextLabel.text =
                        [NSString stringWithFormat:@"%d%%", sizePct ];
                    break;
            }
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *c;
    switch( indexPath.row ) {
        case DEFAULT_FONT_ROW:
            c = [[FontChooserViewController alloc] initWithFont:self.defaultFont
                                                    allowDefault:false
                                                        delegate:self];
            break;
        case FONT_SIZE_ROW:
            c = [[FontSizeChooserViewController alloc] initWithSize:self.fontSize
                                                            delegate:self];
    }
    c.preferredContentSize = self.preferredContentSize;
    [self.navigationController pushViewController:c animated:YES];
}

#pragma mark - TypeLink connection delegate

- (void)connectionFailed:(TypeLinkConnection *)conn
          withStatusCode:(int)statusCode
                 message:(NSString *)msg
{
	self.navigationItem.rightBarButtonItem = saveButton;
    
    UIAlertView *alert;
    
    NSString *message;
	if( statusCode == 0 ) {
		message = @"Could not connect to TypeLink server. Please make sure you're connected to the internet and try again.";
	} else if( [[msg substringToIndex:6] isEqualToString:@"<html>"] ) {
		message = @"A server error occurred. Please try again.";
    } else {
        message = @"An unknown error occurred.";
    }
    
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"OK",nil];
    
	[alert show];
}

- (void)accountConnectionFinished:(TypeLinkConnection *)conn
                         withUser:(User *)u
{
    NSLog(@"got user for first time");
    self.user = u;
    self.defaultFont = user.defaultFont;
    [self.tableView reloadData];
}

- (void)saveAccountConnectionFinished:(TypeLinkConnection *)conn
                             withUser:(User *)u
{
	self.navigationItem.rightBarButtonItem = saveButton;
    
    self.user = u;
    [User setCurrentUser:u];
    [delegate modalDismiss];
}

#pragma mark - Button handlers

- (IBAction) save {
	self.navigationItem.rightBarButtonItem = activityItem;
    
    self.user.email = self.emailField.text;
    self.user.sendEmails = self.sendEmails.on;
    self.settings.lock = [NSNumber numberWithBool:self.lockOnExit.on];
    
    self.user.defaultFont = defaultFont;
    self.settings.fontSize = [NSNumber numberWithFloat:fontSize];
    
    typeLinkConnection = [[TypeLinkService currentService] saveAccount:self.user
                                                          withDelegate:self];
}

- (IBAction) cancel {
	[delegate modalDismiss];
}

#pragma mark - Modal delegate

- (void) updateFont:(Font *)f {
    self.defaultFont = f;
//    user.defaultFont = font;
    [tableView reloadData];
}

- (void) updateFontSize:(float)s {
    self.fontSize = s;
//    settings.fontSize = [NSNumber numberWithFloat:size];
    [tableView reloadData];
}

@end
