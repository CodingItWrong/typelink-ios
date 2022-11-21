//
//  ActivityBarButtonItem.h
//  TypeLinkData
//
//  Created by Josh Justice on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActivityBarButtonItem : UIBarButtonItem {
    UIActivityIndicatorView *activity;
}

@property (nonatomic,retain) UIActivityIndicatorView *activity;

- (id) initAsPopover:(BOOL)popover;

@end
