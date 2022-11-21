//
//  TextTableViewCell.h
//  TypeLinkData
//
//  Created by Josh Justice on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextTableViewCell : UITableViewCell {
	UITextField *_textField;
	CGFloat _labelWidth;
}

@property (nonatomic,retain) UITextField *_textField;
@property (nonatomic,assign) CGFloat _labelWidth;

@end
