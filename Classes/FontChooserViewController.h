//
//  FontChooserViewController.h
//  TypeLinkData
//
//  Created by Josh Justice on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Font;
@class TypeLinkConnection;
@protocol ModalDelegate;

@interface FontChooserViewController : UITableViewController {
    Font *selectedFont;
    BOOL allowDefault;
    id <ModalDelegate> delegate;
    TypeLinkConnection *typeLinkConnection;
}

@property (nonatomic,retain) Font *selectedFont;
@property (nonatomic,assign) BOOL allowDefault;
@property (nonatomic,retain) id <ModalDelegate> delegate;
@property (nonatomic,retain) TypeLinkConnection *typeLinkConnection;

-(id)initWithFont:(Font *)selectedFont
     allowDefault:(BOOL)allowDefault
		 delegate:(id <ModalDelegate>)delegate;

@end
