//
//  AboutViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface AboutViewController : UIViewController<ModalDelegate> {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UILabel *versionLabel;
}

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) IBOutlet UILabel *versionLabel;

@end
