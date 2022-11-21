//
//  TableSettingsViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TableSettingsViewController.h"
#import "Settings.h"
#import "ModalDelegate.h"
#import "RootViewController.h"
#import "TextTableViewCell.h"
#import "User.h"

#define FIELD_SECTION		0
#define REGISTER_SECTION	1

#define USERNAME_ROW 0
#define PASSWORD_ROW 1

#define REGISTER_BUTTON_ROW	0


@implementation TableSettingsViewController

@synthesize settings;
@synthesize delegate;
@synthesize error;
@synthesize popover;
@synthesize usernameField;
@synthesize passwordField;
@synthesize navBar;


-(id)initWithSettings:(Settings *)s
			 delegate:(id <ModalDelegate>)d
{
	return [self initWithSettings:s
						 delegate:d
							error:NO
						  popover:NO];
}

-(id)initWithSettings:(Settings *)s
			 delegate:(id <ModalDelegate>)d
				error:(BOOL)e
			  popover:(BOOL)p {
	if( ( self = [self initWithNibName:@"TableSettingsViewController"
							  bundle:[NSBundle mainBundle]] ) )
	{
		self.settings = s;
		self.delegate = d;
		self.error = e;
		self.popover = p;
	}
	return self;
}

#pragma mark -
#pragma mark Button handlers

- (IBAction)save {
	settings.username = usernameField.text;
	settings.password = passwordField.text;
	
	// TODO: better way to get MOC
	RootViewController *rvc =
	(RootViewController *)[self.navigationController.navigationController.viewControllers objectAtIndex:0];
	
	NSError *myError;
	if(![rvc.managedObjectContext save:&myError]) {
		// TODO: handle error
		//NSLog(@"Error saving settings: %@", [myError localizedDescription]);
		NSLog(@"Error saving settings");
	}
	
	[User setCurrentUser:nil];
	
	[delegate modalDismiss];
}

- (IBAction)cancel {
	[delegate modalDismiss];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if( section == REGISTER_SECTION ) {
		return @"Don't have an account?";
	} else {
		return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case FIELD_SECTION:		return 2;
		case REGISTER_SECTION:	return 1;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	static NSString *TextCellIdentifier = @"TextCell";
	
	UITableViewCell *cell;
	
	if( FIELD_SECTION == indexPath.section ) {
		cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
		if( cell == nil ) {
			cell = [[TextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier];
		}
	} else {
		NSLog(@" ");
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
	}
	
	switch( indexPath.section ) {
		case FIELD_SECTION:
			// Configure the cell...
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			((TextTableViewCell *)cell)._labelWidth = 100.0f;
			switch( indexPath.row ) {
				case USERNAME_ROW:
					cell.textLabel.text = @"User ID";
					self.usernameField = ((TextTableViewCell *)cell)._textField;
					usernameField.text = settings.username;
					usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
					usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
					usernameField.secureTextEntry = NO;
					break;
				case PASSWORD_ROW:
					cell.textLabel.text = @"Password";
					self.passwordField = ((TextTableViewCell *)cell)._textField;
					passwordField.text = settings.password;
					passwordField.secureTextEntry = YES;
			}
			return cell;
			break;
			/*
		case NOTE_SECTION:
			NSLog(@"");
			CGRect contentFrame = CGRectMake(10.0f, 0.0f, 300.0f, 42.0f);
			if( error ) {
				self.errorLabel = [[[UILabel alloc] initWithFrame:contentFrame] autorelease];
				errorLabel.text = @"Username or password incorrect. Please re-enter them and try again.";
				errorLabel.textColor = [UIColor redColor];
				errorLabel.backgroundColor = [UIColor clearColor];
				errorLabel.lineBreakMode = UILineBreakModeWordWrap;
				errorLabel.numberOfLines = 0; // any
				NSLog(@"error label frame: %@", NSStringFromCGRect(errorLabel.frame));
				
				[cell.contentView addSubview:errorLabel];
			} else {
				self.registerView = [[[UIWebView alloc] initWithFrame:contentFrame] autorelease];
				self.registerView.backgroundColor = [UIColor clearColor];
				self.registerView.opaque = NO;
				[registerView loadHTMLString:@"<html><head></head><body style='background-color:transparent; font: 17px Helvetica;margin:0'>Sign up for a free account at <a href='http://typelink.net/session/login#signup'>http://typelink.net</a></script></body></html>"
									 baseURL:nil];
				[registerView setDelegate:self];
				
				// prevent rubberbanding
				id scrollView = [registerView.subviews objectAtIndex:0];
				if( [scrollView respondsToSelector:@selector(setStrollEnabled:)] ) {
					[scrollView setScrollEnabled:NO];  //to stop scrolling completely
				}
				if( [scrollView respondsToSelector:@selector(setBounces:)] ) {
					[scrollView setBounces:NO]; //to stop bouncing
				}
				
				[cell.contentView addSubview:registerView];
				
				NSLog(@"row height: %f", tableView.rowHeight);
			}
			break;
			 */
		case REGISTER_SECTION:
			cell.textLabel.text = @"Register For Free";
			break;
	}
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
}
 */

/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if( error ) {
		return 42.0f;
	} else {
		return 0.0f;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	CGRect contentFrame = CGRectMake(10.0f, 5.0f, 300.0f, 42.0f);
	
	if( error ) {
		self.errorLabel = [[[UILabel alloc] initWithFrame:contentFrame] autorelease];
		errorLabel.text = @"Username or password incorrect. Please re-enter them and try again.";
		errorLabel.textColor = [UIColor redColor];
		errorLabel.backgroundColor = [UIColor clearColor];
		errorLabel.lineBreakMode = UILineBreakModeWordWrap;
		errorLabel.numberOfLines = 0; // any
		NSLog(@"error label frame: %@", NSStringFromCGRect(errorLabel.frame));
		
		[view addSubview:errorLabel];
	} else {
		self.registerView = [[[UIWebView alloc] initWithFrame:contentFrame] autorelease];
		self.registerView.backgroundColor = [UIColor clearColor];
		self.registerView.opaque = NO;
		self.registerView.userInteractionEnabled = YES;
		[registerView loadHTMLString:@"<html><head></head><body style='background-color:transparent; font: 17px Helvetica;margin:0'>Sign up for a free account at <a href='http://typelink.net/session/login#signup'>http://typelink.net</a></script></body></html>"
							 baseURL:nil];
		[registerView setDelegate:self];
		
		[view addSubview:registerView];
	}
	
	return view;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch( indexPath.section ) {
        case FIELD_SECTION: {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			[((TextTableViewCell *)cell)._textField becomeFirstResponder];
			break;
        }
		case REGISTER_SECTION:
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			[delegate modalDismissAndShowRegister];
			break;
	}
	if( REGISTER_SECTION == indexPath.section ) {
	}
}


#pragma mark -
#pragma mark Web view delegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"request URL: %@", request.URL);
	if ([[request.URL scheme] isEqual:@"about"]) {
		// opening new page window--still blank
		return YES;
	} else {
		// open all other urls in safari
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
}

#pragma mark -
#pragma mark Superclass method overrides

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.navigationItem.title = @"Account";
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;

    if( !popover ) {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancel)];
    }
	
	if( error ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"User ID or password incorrect. Please re-enter them and try again."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil]; 
		[alert show];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
		|| interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
