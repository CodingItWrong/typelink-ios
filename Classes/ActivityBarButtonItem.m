//
//  ActivityBarButtonItem.m
//  TypeLinkData
//
//  Created by Josh Justice on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityBarButtonItem.h"


@implementation ActivityBarButtonItem

@synthesize activity;

- (id) initAsPopover:(BOOL)popover {
    // set up activity indicator
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);  
	UIActivityIndicatorView *myActivity = 
        [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[myActivity sizeToFit];
	myActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);  
    [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [myActivity startAnimating];
    
    // init bar button item with activity indicator
	if( ( self = [self initWithCustomView:myActivity] ) ) {
        self.activity = myActivity;
    }
    return self;
}

@end
