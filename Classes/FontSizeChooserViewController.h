//
//  FontChooserViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ModalDelegate;

@interface FontSizeChooserViewController : UITableViewController {
    float selectedSize;
    id <ModalDelegate> delegate;
    NSArray *sizeOptions;
}

@property (nonatomic,assign) float selectedSize;
@property (nonatomic,retain) id <ModalDelegate> delegate;
@property (nonatomic,retain) NSArray *sizeOptions;

-(id)initWithSize:(float)selectedSize
		 delegate:(id <ModalDelegate>)delegate;

@end
