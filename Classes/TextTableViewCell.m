//
//  TextTableViewCell.m
//  TypeLinkData
//
//  Created by Josh Justice on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TextTableViewCell.h"


@implementation TextTableViewCell

@synthesize _textField;
@synthesize _labelWidth;

- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_labelWidth = 100.0f;
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
//		_textField.backgroundColor = [UIColor redColor];
		[self.contentView addSubview:_textField];
//		self.accessoryView = _textField; // do not do this -- messes up the manual placement
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.textLabel.frame = CGRectMake( 15.0f, 13.0f, self._labelWidth, 20.0f );
	
	CGRect newFrame = CGRectMake( self._labelWidth + 15.0f, 12.0f,
								 (self.contentView.frame.size.width - self._labelWidth - 25.0f), 24.0f);
	//CGRect newFrame = CGRectMake( 100.0f, 12.0f, (self.contentView.frame.size.width - 100.0f), 24.0f);

	_textField.frame = newFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

@end
