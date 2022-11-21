//
//  LockScreenViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
@class Settings;

@interface LockScreenViewController : UIViewController <UITextFieldDelegate> {
    Settings *settings;
    IBOutlet UITextField *passwordField;
    __unsafe_unretained id<ModalDelegate> delegate;
}

@property (nonatomic,retain) Settings *settings;
@property (nonatomic,assign) id<ModalDelegate> delegate;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;

- (IBAction) attemptUnlock;

- (id) initWithSettings:(Settings *)s
               delegate:(id<ModalDelegate>)d;

@end
