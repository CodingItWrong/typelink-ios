//
//  LockScreenViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LockScreenViewController.h"
#import "Settings.h"

@implementation LockScreenViewController

@synthesize settings;
@synthesize delegate;
@synthesize passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithSettings:(Settings *)s
               delegate:(id<ModalDelegate>)d
{
    self = [self initWithNibName:@"LockScreenViewController"
                          bundle:[NSBundle mainBundle]];
    if(self)
    {
        self.settings = s;
        self.delegate = d;
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
    [passwordField becomeFirstResponder];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
    || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Handlers

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    [self attemptUnlock];
    return YES;
}

- (IBAction) attemptUnlock {
    if( [settings.password isEqualToString:passwordField.text] ) {
        [delegate modalDismiss];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your password was incorrect. Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [passwordField becomeFirstResponder]; // in case deselected by enter key
    }
}

@end
