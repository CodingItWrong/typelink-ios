//
//  ProgressViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressViewController : UIViewController {
	IBOutlet UIActivityIndicatorView *activity;
}

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activity;

@end
