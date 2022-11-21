//
//  RegisterTableViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "ModalDelegate.h"
#import "Settings.h"
#import "TypeLinkService.h"
#import "User.h"

#import "TextTableViewCell.h"

#define USERNAME_ROW			0
#define EMAIL_ROW				1
#define PASSWORD_ROW			2
#define PASSWORD_CONFIRM_ROW	3

@implementation RegisterTableViewController

@synthesize popover;
@synthesize settings;
@synthesize delegate;
@synthesize usernameField;
@synthesize emailField;
@synthesize passwordField;
@synthesize passwordConfirmField;
@synthesize navBar;
@synthesize typeLinkConnection;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(id)initWithSettings:(Settings *)s
			 delegate:(id <ModalDelegate>)d
			  popover:(BOOL)p {
	if( ( self = [self initWithNibName:@"RegisterTableViewController"
							  bundle:[NSBundle mainBundle]] ) )
	{
		self.settings = s;
		self.delegate = d;
		self.popover = p;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.navigationItem.title = @"Register";
    
    UIBarButtonItem *registerButton = [[UIBarButtonItem alloc] initWithTitle:@"Register"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doRegister)];
    self.navigationItem.rightBarButtonItem = registerButton;
    
    if( !popover ) {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancel)];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
		|| interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark -
#pragma mark Button handlers


-(IBAction)doRegister {
	
	// validate
	NSString *error = nil;
	NSLog(@"username = %@", usernameField.text);
	if( nil == usernameField.text || [usernameField.text isEqualToString:@""] ) {
		error = @"Please enter a username.";
	} else if( nil == emailField.text || [emailField.text isEqualToString:@""] ) {
		error = @"Please enter your e-mail address.";
	} else if( nil == passwordField.text || [passwordField.text isEqualToString:@""] ) {
		error = @"Please choose a password.";
	} else if( 6 > [passwordField.text length] ) {
		error = @"Please choose a password at least 6 characters long.";
	} else if( ![passwordField.text isEqualToString:passwordConfirmField.text] ) {
		error = @"Passwords do not match.";
	}
	if( nil != error ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:error
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	// register
	User *user = [[User alloc] init];
	user.login = usernameField.text;
	user.email = emailField.text;
	user.password = passwordField.text;
	typeLinkConnection = [[TypeLinkService currentService] registerUser:user withDelegate:self];
	 
	 // if success, update settings and close modal
}

-(IBAction)cancel {
	[delegate modalDismiss];
}

#pragma mark -
#pragma mark Ajax callbacks

-(void)registerConnectionFinished:(TypeLinkConnection *)conn
						 withUser:(User *)user
{
	settings.username = user.login;
	NSLog(@"populating password %@", passwordField.text);
	settings.password = passwordField.text; // not returned with ajax
	[delegate modalDismiss];
}

- (void)connectionFailed:(TypeLinkConnection *)connection
		  withStatusCode:(NSInteger)statusCode
				 message:(NSString *)message
{
	NSLog(@"message = %@",message);
	
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


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[TextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	((TextTableViewCell *)cell)._labelWidth = 140.0f;
	UITextField *textField = ((TextTableViewCell *)cell)._textField;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch( indexPath.row ) {
		case USERNAME_ROW:
			cell.textLabel.text = @"User ID";
			self.usernameField = textField;
			textField.keyboardType = UIKeyboardTypeDefault;
			textField.secureTextEntry = NO;
			break;
		case EMAIL_ROW:
			cell.textLabel.text = @"E-mail";
			self.emailField = textField;
			textField.keyboardType = UIKeyboardTypeEmailAddress;
			textField.secureTextEntry = NO;
			break;
		case PASSWORD_ROW:
			cell.textLabel.text = @"Password";
			self.passwordField = textField;
			textField.keyboardType = UIKeyboardTypeDefault;
			textField.secureTextEntry = YES;
			break;
		case PASSWORD_CONFIRM_ROW:
			cell.textLabel.text = @"Retype Passwd";
			self.passwordConfirmField = textField;
			textField.keyboardType = UIKeyboardTypeDefault;
			textField.secureTextEntry = YES;
			break;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[((TextTableViewCell *)cell)._textField becomeFirstResponder];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
