//
//  EditPageViewController.m
//  TypeLinkNav
//
//  Created by Josh Justice on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditPageViewController.h"
#import "ActivityBarButtonItem.h"
#import "Font.h"
#import "ModalDelegate.h"
#import "Page.h"
#import "Settings.h"
#import "TypeLinkService.h"
#import "User.h"

@interface EditPageViewController()
-(void)textChanged:(NSNotification*)notification;
-(void)resizeTextField;
-(void)saveInternal;
-(void)disableSaveBtn;
-(void)enableSaveBtn;
-(void)modalDismiss;
@end


@implementation EditPageViewController

@synthesize textView;

@synthesize closeBtn;
@synthesize saveBtn;
@synthesize enabledSaveBtn;
@synthesize activityItem;

@synthesize typeLinkConnection;
@synthesize page;
@synthesize text;
@synthesize savedText;
@synthesize delegate;

@synthesize originalTextViewFrame;
@synthesize keyboardHeight;
@synthesize anyChangesSaved;
@synthesize changed;
@synthesize closeAfterSave;
@synthesize firstLayout;

-(id)initWithPage:(Page *)p
		 delegate:(id <ModalDelegate>)d
{
	return [self initWithPage:p
						 text:nil
					 delegate:d];
}

-(id)initWithPage:(Page *)p
			 text:(NSString *)t
		 delegate:(id <ModalDelegate>)d
{
	if( (self = [self initWithNibName:@"EditPageViewController"
							 bundle:[NSBundle mainBundle]]) )
	{
		self.page = p;
		self.text = t;
		self.savedText = p.content;

		self.delegate = d;
		
		self.keyboardHeight = 0.0;
		self.changed = NO;
		self.anyChangesSaved = NO;
        self.firstLayout = YES;
	}
	return self;
}

#pragma mark -
#pragma mark Button handlers

-(IBAction)save {
	self.closeAfterSave = NO;
	[self saveInternal];
}

- (void)saveInternal {
	// replace save button with activity indicator]
	self.navigationItem.rightBarButtonItem = activityItem;
	closeBtn.enabled = NO;
	
	page.content = textView.text;
	typeLinkConnection = [[TypeLinkService currentService] savePage:page
                                                          withTitle:page.title
                                                           delegate:self];
}

- (void)connectionFailed:(TypeLinkConnection *)connection
		  withStatusCode:(NSInteger)statusCode
				 message:(NSString *)message
{
 	self.navigationItem.rightBarButtonItem = enabledSaveBtn;
	[activity stopAnimating];
	closeBtn.enabled = YES;
	
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

-(void)saveConnectionFinished:(TypeLinkConnection *)connection
					 withPage:(Page *)myPage
{
	self.navigationItem.rightBarButtonItem = saveBtn;
	[activity stopAnimating];
	closeBtn.enabled = YES;
	
	self.savedText = page.content;
	self.anyChangesSaved = YES;
	
	if( [textView.text isEqualToString:savedText] ) {
		self.changed = NO;
		[self disableSaveBtn];
	} else {
		self.changed = YES;
		[self enableSaveBtn];
	}
	
	self.page = myPage;
	
	if( closeAfterSave ) {
		[self modalDismiss];
	}
}

-(IBAction)close {
	if( !changed ) {
		[self modalDismiss];
	} else {
		UIActionSheet *sheet =
		[[UIActionSheet alloc] initWithTitle:@"Save changes?"
									delegate:self
						   cancelButtonTitle:@"Cancel"
					  destructiveButtonTitle:@"Discard"
						   otherButtonTitles:@"Save",nil];
        [sheet showFromBarButtonItem:closeBtn
                        animated:YES];
	}
}

- (void)modalDismiss {
	if( anyChangesSaved ) {
		[delegate modalDismissAndUpdatePage:page];
	} else {
		[delegate modalDismiss];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == [actionSheet destructiveButtonIndex] ) {
		[self modalDismiss];
	} else if( buttonIndex == 1 ) { // save
		self.closeAfterSave = YES;
		[self saveInternal];
	} else {
		// clicked off button list or cancelled -- do nothing
	}
}

- (void)disableSaveBtn
{
	NSLog(@"disableSaveBtn");
	self.navigationItem.rightBarButtonItem = saveBtn;
	//[self.navBar setNeedsDisplay];
}

- (void)enableSaveBtn
{
	NSLog(@"enableSaveBtn");
	self.navigationItem.rightBarButtonItem = enabledSaveBtn;
	//[self.navBar setNeedsDisplay];
}

#pragma mark -
#pragma mark Notifications

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	NSLog(@"*** willRotateToInterfaceOrientation");
	
	if( keyboardHeight != 0 ) {
		// remove any keyboard height shrinking on text field
		keyboardHeight = 0;
		[self resizeTextField];
		
		// invalidate frame so we have to reload after resize
		originalTextViewFrame = CGRectNull;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"*** didRotateFromInterfaceOrientation");
	
	// save new text view size
	originalTextViewFrame = textView.frame;
	
	// resize
	[self resizeTextField];
}

-(void)keyboardWillShow:(NSNotification *)note
{
	// called when keyboard shown on start, on bluetooth disable, or after rotate
	NSLog(@"*** keyboardWillShow");
	
	// save keyboard height
	CGRect t;
	[[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &t];
	keyboardHeight = t.size.height;
	NSLog(@"keyboard height: %f", keyboardHeight);
	
	// resize
	[self resizeTextField];
}

-(void)keyboardWillHide:(NSNotification *)note
{
	NSLog(@"*** keyboardWillHide");
	keyboardHeight = 0.0;
	
	// resize
	[self resizeTextField];
}

-(void)resizeTextField {
	NSLog(@"*** resizeTextField");
	if( CGRectEqualToRect(originalTextViewFrame, CGRectNull) ) {
        NSLog(@"can't resize text field: originalTextViewFrame is null");
	} else {
        textViewBottomConstraint.constant = keyboardHeight;
        NSLog(@"new text field bottom constraint constant: %f", textViewBottomConstraint.constant);
    }
}

- (void)textChanged:(NSNotification *)notification {
	//NSLog(@"hi");
	BOOL nowChanged = ![textView.text isEqualToString:savedText];
	//NSLog(@"self.changed = %@", self.changed ? @"YES" : @"NO" );
	//NSLog(@"nowChanged = %@", nowChanged ? @"YES" : @"NO" );
	if( self.changed && !nowChanged ) {
		self.changed = NO;
		[self disableSaveBtn];
	} else if( !self.changed && nowChanged ) {
		self.changed = YES;
		[self enableSaveBtn];
	}
}



#pragma mark -
#pragma mark Superclass method overrides

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    NSLog(@"*** viewDidLoad");
//	originalTextViewFrame = CGRectNull;
//	originalTextViewFrame = textView.frame;
    NSLog(@"originalTextViewFrame height %f", originalTextViewFrame.size.height);
	
    self.navigationItem.title = page.title;
    
    self.saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"Saved"
                                                    style:UIBarButtonItemStyleDone
                                                   target:nil
                                                   action:nil];
    self.saveBtn.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    self.closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(close)];
    self.navigationItem.leftBarButtonItem = closeBtn;
    
	// set up active version of save btn
	self.enabledSaveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                        target:self
                                                                        action:@selector(save)];
	
	// set up keyboard notifications
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
	[nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
	[nc addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
	
	// ui adjustments
    [super viewDidLoad];
//	navBar.topItem.title = page.title;
	if( text ) {
		// reloading edit panel from app quit
		textView.text = text;
		changed = YES;
		[self enableSaveBtn];
	} else {
		// regular edit
		textView.text = page.content;
		changed = NO;
		// saveBtn not enabled by default
	}
	
    self.activityItem = [[ActivityBarButtonItem alloc] initAsPopover:false];
//	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);  
//	UIActivityIndicatorView *myActivity = 
//        [[UIActivityIndicatorView alloc] initWithFrame:frame];
//	[myActivity sizeToFit];
//	myActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);  
//    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//    } else {
//        [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
//    }
//	self.activity = myActivity;
//	[myActivity release];
//	UIBarButtonItem *myActivityItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
//	self.activityItem = myActivityItem;
//	[myActivityItem release];
	
	Font *fontToUse = page.font;
	if( nil == fontToUse ) {
		fontToUse = [User currentUser].defaultFont;
	}
    float size = (int)( 16.0 * [[Settings currentSettings].fontSize floatValue] );
    UIFont *myFont = [UIFont fontWithName:fontToUse.iOSCode size:size];
    if( myFont ) {
        textView.font = myFont;
    }
//	[textView becomeFirstResponder];
    
    if( ![[UIViewController class] instancesRespondToSelector:@selector(viewDidLayoutSubviews)] ) {
        NSLog(@"calling viewDidLayoutSubviews manually");
        // call it manually
        [self viewDidLayoutSubviews];
    }
	
	// if reloading text from app quit, alert user
	if( text ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsaved Changes"
														message:@"You quit TypeLink without saving changes to this page. You can save changes now, but if you made changes to this page through the web site since then, they will be overwritten."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
	}
}

-(void)viewDidLayoutSubviews {
    NSLog(@"*** viewDidLayoutSubviews");
    if(firstLayout) {
        firstLayout = NO;
        originalTextViewFrame = textView.frame;
        [textView becomeFirstResponder];
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
