//
//  AboutViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize scrollView;
@synthesize versionLabel;

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

- (void)modalDismiss {
	[self dismissViewControllerAnimated:YES completion:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[scrollView setContentSize:CGSizeMake(320.0f, 350.0f)];
	
	NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
	versionLabel.text = [dict objectForKey:@"CFBundleVersion"];
	NSLog(@"about viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
	|| interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

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
