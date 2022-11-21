//
//  TablePageSettingsViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 11/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TablePageSettingsViewController.h"
#import "ActivityBarButtonItem.h"
#import "Font.h"
#import "FontChooserViewController.h"
#import "ModalDelegate.h"
#import "Page.h"
#import "TextTableViewCell.h"
#import "TypeLinkService.h"
#import "User.h"

#define MAIN_SECTION  0
#define ALIAS_SECTION 1
#define SHARE_SECTION 2

#define TITLE_ROW  0
#define PUBLIC_ROW 1
#define FONT_ROW 2

@implementation TablePageSettingsViewController

@synthesize tableView;
@synthesize titleField;
@synthesize publiclyVisible;
@synthesize saveButton;
@synthesize alert;

@synthesize activityItem;

@synthesize prevTitle;
@synthesize nextTitle;
@synthesize user;
@synthesize page;
@synthesize delegate;
@synthesize popover;

@synthesize typeLinkConnection;

//@synthesize shareToField;
@synthesize shareToAdd;
@synthesize shareToDelete;
//@synthesize aliasField;
@synthesize aliasToAdd;
@synthesize aliasToDelete;

-(id)initWithUser:(NSString *)u
		 pageName:(NSString *)pn
		 delegate:(id <ModalDelegate>)d
		  popover:(BOOL)p
{
	if( ( self = [self initWithNibName:@"TablePageSettingsViewController"
							  bundle:[NSBundle mainBundle]] ) )
	{
		self.user = u;
		self.delegate = d;
		self.nextTitle = pn;
		self.popover = p;
		
		Page *p = [[Page alloc] init];
		self.page = p;
		self.page.content = @"";
		
		// preload fonts
//		if( nil == [Font allFonts] ) {
//			NSLog(@"all fonts are nil");
//			[service getFontsWithDelegate:self];
//		} else { 
//			NSLog(@"all fonts are not nil: %@", [Font allFonts]);
//		}
	}
	return self;
}

-(id)initWithPage:(Page *)pg
		 delegate:(id <ModalDelegate>)d
		  popover:(BOOL)p
{
	if( ( self = [self initWithNibName:@"TablePageSettingsViewController"
							  bundle:[NSBundle mainBundle]] ) )
	{
		self.page = pg;
		self.prevTitle = pg.title;
		self.delegate = d;
		self.popover = p;
		
		
		// preload fonts
//		if( nil == [Font allFonts] ) {
//			NSLog(@"all fonts are nil");
//			[service getFontsWithDelegate:self];
//		} else { 
//			NSLog(@"all fonts are not nil: %@", [Font allFonts]);
//		}
	}
	return self;
}


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

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self
                                                                    action:@selector(save)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
	if( page ) {
		self.navigationItem.title = @"Page Settings";
//		self.hint.hidden = YES;
		
	} else {
//		self.hint.hidden = (nil != nextTitle);
		
		self.saveButton.title = @"Create";
		self.navigationItem.title = @"New Page";
//		self.hint.hidden = NO;
    }
	
	if( !popover ) {
//		self.navBar.topItem.leftBarButtonItem = nil; // no cancel
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancel)];
	}
	
    // create activity indicator
    self.activityItem = [[ActivityBarButtonItem alloc] initAsPopover:popover];
//	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);  
//	UIActivityIndicatorView *myActivity = 
//	[[UIActivityIndicatorView alloc] initWithFrame:frame];
//	[myActivity sizeToFit];
//	myActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);  
//    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//    } else {
//        [myActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
//    }
//	self.activity = myActivity;
//    [activity startAnimating];
//	[myActivity release];
//	UIBarButtonItem *myActivityItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
//	self.activityItem = myActivityItem;
//	[myActivityItem release];
}

// Override to allow orientations other than the default portrait orientation.
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if( nextTitle ) {
		return 1; // hide sharing for new page
	} else {
		return 3;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch( section ) {
//		case FONT_SECTION:  return @"Font";
		case ALIAS_SECTION: return @"Aliases";
		case SHARE_SECTION: return @"Shared To";
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch( section ) {
		case MAIN_SECTION:  return 3;
//		case FONT_SECTION:
//			if( nil == [Font allFonts] ) {
//				return 0;
//			} else {
//				return [[Font allFonts] count]+1;
//			}
		case ALIAS_SECTION: return [page.aliases count] + 1;
		case SHARE_SECTION: return [page.sharedTo count] + 1;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	static NSString *TextCellIdentifier = @"TextCell";
	static NSString *DetailCellIdentifier = @"MyDetailCell";
	
	UITableViewCell *cell;
	if( MAIN_SECTION == indexPath.section
	   && TITLE_ROW == indexPath.row )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
		if( cell == nil ) {
			cell = [[TextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:TextCellIdentifier];
		}
    } else if( MAIN_SECTION == indexPath.section
              && FONT_ROW == indexPath.row )
    {
		cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier];
		if( cell == nil ) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:DetailCellIdentifier];
		}
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
		}
	}
    
    // Configure the cell...
	switch( indexPath.section ) {
		case MAIN_SECTION:
			switch( indexPath.row ) {
				case TITLE_ROW:
                    cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = @"Title";
					cell.textLabel.textColor = [UIColor blackColor];
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					self.titleField = ((TextTableViewCell *)cell)._textField;
					if( page.title ) {
						self.titleField.text = page.title;
					} else {
						self.titleField.text = nextTitle;
						
						// only pre-select field if it's a new page
						[titleField becomeFirstResponder];
					}
					if( [page.title isEqualToString:@"Home"] ) {
						self.titleField.enabled = NO;
						self.titleField.textColor = [UIColor lightGrayColor];
					}
					titleField.delegate = self;
					titleField.returnKeyType = UIReturnKeyDone;
					break;
                case PUBLIC_ROW: {
                    cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = @"Publicly Visible";
					cell.textLabel.textColor = [UIColor colorWithRed:0.0
															   green:0.0
																blue:0.93
															   alpha:1.0]; // #0000EE
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
					[cell addSubview:mySwitch];
					cell.accessoryView = mySwitch;
					self.publiclyVisible = mySwitch;
					self.publiclyVisible.on = page.publiclyVisible;
					break;
                }
                case FONT_ROW:
                    cell.textLabel.text = @"Font";
//                    cell.detailTextLabel.text = @"Use default";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                    if( nil == cell.detailTextLabel ) {
//                        NSLog(@"no detailTextLabel!");
//                    }
                    UIFont *myFont;
                    if( nil == page.font ) {
                        NSLog(@"default font");
                        cell.detailTextLabel.text = @"Use default";
                        myFont = [UIFont fontWithName:@"Helvetica" size:16.0f];
                        
                    } else {
                        NSLog(@"font: %@", page.font.name);
                        cell.detailTextLabel.text = page.font.name;
                        myFont = [UIFont fontWithName:page.font.iOSCode size:16.0f];
                    }
                    if( myFont ) {
                        cell.detailTextLabel.font = myFont;
                    }
//                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    break;
			}
			break;
//		case FONT_SECTION:
//			cell.textLabel.textColor = [UIColor blackColor];
//			if( 0 == indexPath.row ) {
//				cell.textLabel.text = @"Use default";
//				cell.textLabel.font = [UIFont fontWithName:[User currentUser].defaultFont.iOSCode size:16.0f];
//				cell.accessoryView = nil;
//				if( nil == page.font ) {
//					cell.accessoryType = UITableViewCellAccessoryCheckmark;
//				} else {
//					cell.accessoryType = UITableViewCellAccessoryNone;
//				}
//			} else {
//				NSArray *fonts = [Font allFonts];
//				int idx = indexPath.row-1;
//				Font *font = [fonts objectAtIndex:idx];
//				cell.textLabel.text = font.name;
//				cell.textLabel.font = [UIFont fontWithName:font.iOSCode size:16.0f];
//				cell.accessoryView = nil;
//				if( [page.font.name isEqualToString:font.name] ) {
//					cell.accessoryType = UITableViewCellAccessoryCheckmark;
//				} else {
//					cell.accessoryType = UITableViewCellAccessoryNone;
//				}
//			}
//			break;
		case ALIAS_SECTION:
			cell.textLabel.textColor = [UIColor blackColor];
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			if( indexPath.row == [page.aliases count] ) {
				cell.textLabel.text = @"Add Alias…";
			} else {
				cell.textLabel.text = [page.aliases objectAtIndex:indexPath.row];
			}
			break;
		case SHARE_SECTION:
			cell.textLabel.textColor = [UIColor colorWithRed:0.33
													   green:0.1
														blue:0.55
													   alpha:1.0]; // #551A8B
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			if( indexPath.row == [page.sharedTo count] ) {
				cell.textLabel.text = @"Add Share…";
			} else {
				cell.textLabel.text = [page.sharedTo objectAtIndex:indexPath.row];
			}
			break;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch( indexPath.section ) {
		case MAIN_SECTION:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            switch( indexPath.row ) {
                case TITLE_ROW: {
                    NSLog(@" ");
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    [((TextTableViewCell *)cell)._textField becomeFirstResponder];
                    break;
                }
                case FONT_ROW: {
                    NSLog(@" ");
                    FontChooserViewController *c = [[FontChooserViewController alloc] initWithFont:self.page.font
                                                                                      allowDefault:true
                                                                                          delegate:self];
                    c.preferredContentSize = self.preferredContentSize;
                    [self.navigationController pushViewController:c animated:YES];
                    break;
                }
			}
			break;
//		case FONT_SECTION:
//			NSLog(@"");
//			NSIndexPath *loopIndexPath;
//			UITableViewCell *cell;
//			for( int i = 0; i <= [[Font allFonts] count]; i++ ) {
//				NSUInteger indexArr[] = { FONT_SECTION, i };
//				loopIndexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
//				cell = [tableView cellForRowAtIndexPath:loopIndexPath];
//				cell.accessoryType = UITableViewCellAccessoryNone;
//			}
//			
//			cell = [tableView cellForRowAtIndexPath:indexPath];
//			cell.accessoryType = UITableViewCellAccessoryCheckmark;
//			if( 0 == indexPath.row ) {
//				page.font = nil;
//			} else {
//				page.font = [[Font allFonts] objectAtIndex:indexPath.row-1];
//			}
//			if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//			{
//				[delegate updateFont];
//			}
//			break;
		case ALIAS_SECTION:
			if( indexPath.row == [page.aliases count] ) {
				// http://iphonedevelopertips.com/undocumented/alert-with-textfields.html
				self.alert = [[UIAlertView alloc] initWithTitle:@"Add Alias"
                                                        message:@"\n"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Add", nil];
                self.alert.alertViewStyle = UIAlertViewStylePlainTextInput;
				
//				UITextField *utextfield =
//				[[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
//				utextfield.placeholder = @"Alias";
//				[utextfield setBackgroundColor:[UIColor whiteColor]];
//				utextfield.returnKeyType = UIReturnKeyDone;
//				[utextfield addTarget:self
//							   action:@selector(textFieldReturn:)
//					 forControlEvents:UIControlEventEditingDidEndOnExit];
//				[alert addSubview:utextfield];
//				self.aliasField = utextfield;
				
				// Move a little to show up the keyboard
				// iOS < 4 only
//				NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
//				NSLog(@"iOS version: %@", systemVersion );
//				if( [[systemVersion substringToIndex:1] intValue] < 4 ) {
//					CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
//					[alert setTransform:transform];
//				}
				
				[alert show];
				
//				[utextfield becomeFirstResponder];
//				[utextfield release];
			} else {
				// save alias to delete
				self.aliasToDelete = [page.aliases objectAtIndex:indexPath.row];
				
				// show prompt
				NSString *message = [NSString stringWithFormat:@"Remove alias %@?",
									 self.aliasToDelete];
				UIActionSheet *sheet =
				[[UIActionSheet alloc] initWithTitle:message
											delegate:self
								   cancelButtonTitle:@"Cancel"
							  destructiveButtonTitle:@"Remove"
								   otherButtonTitles:nil];
				
				// get cell to show it from
				UITableViewCell *cell =
				[self.tableView cellForRowAtIndexPath:indexPath];
				
                [sheet showFromRect:cell.frame
                             inView:self.tableView
                           animated:YES];
			}
			break;
		case SHARE_SECTION:
			if( indexPath.row == [page.sharedTo count] ) {
				// http://iphonedevelopertips.com/undocumented/alert-with-textfields.html
				self.alert = [[UIAlertView alloc] initWithTitle:@"Share to"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Share", nil];
                self.alert.alertViewStyle = UIAlertViewStylePlainTextInput;
				
//				UITextField *utextfield =
//				[[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
//				utextfield.placeholder = @"User Name";
//				[utextfield setBackgroundColor:[UIColor whiteColor]];
//				utextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
//				utextfield.autocorrectionType = UITextAutocorrectionTypeNo;
//				utextfield.returnKeyType = UIReturnKeyDone;
//				[utextfield addTarget:self
//							   action:@selector(textFieldReturn:)
//					 forControlEvents:UIControlEventEditingDidEndOnExit];
//				[alert addSubview:utextfield];
//				self.shareToField = utextfield;
//				
//				// Move a little to show up the keyboard
//				// iOS < 4 only
//				NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
//				NSLog(@"iOS version: %@", systemVersion );
//				if( [[systemVersion substringToIndex:1] intValue] < 4 ) {
//					CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
//					[alert setTransform:transform];
//				}
				
				[alert show];
				
//				[utextfield becomeFirstResponder];
//				[utextfield release];
			} else {
				// save share to delete
				self.shareToDelete = [page.sharedTo objectAtIndex:indexPath.row];
				
				// show prompt
				NSString *message = [NSString stringWithFormat:@"Unshare from %@?",
									 self.shareToDelete];
				UIActionSheet *sheet =
				[[UIActionSheet alloc] initWithTitle:message
											delegate:self
								   cancelButtonTitle:@"Cancel"
							  destructiveButtonTitle:@"Unshare"
								   otherButtonTitles:nil];
				
				// get cell to show it from
				UITableViewCell *cell =
					[self.tableView cellForRowAtIndexPath:indexPath];
				
                [sheet showFromRect:cell.frame
                             inView:self.tableView
                           animated:YES];
			}
			break;
	}
		
	// deselect row
	[self.tableView deselectRowAtIndexPath:indexPath
								  animated:YES];
}

#pragma mark -
#pragma mark Alert view delegate methods

-(void)alertView:(UIAlertView *)a
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( [[a title] isEqualToString:@"Share to" ] ) {
		if( a.cancelButtonIndex != buttonIndex ) {
            self.shareToAdd = [a textFieldAtIndex:0].text;
			typeLinkConnection = [[TypeLinkService currentService] sharePage:page
                                                                      toUser:shareToAdd
                                                                    delegate:self];
		}
	} else if( [[a title] isEqualToString:@"Add Alias" ] ) {
		if( a.cancelButtonIndex != buttonIndex ) {
			self.aliasToAdd = [a textFieldAtIndex:0].text;
			typeLinkConnection = [[TypeLinkService currentService] addAlias:aliasToAdd
                                                                     toPage:page
                                                                   delegate:self];
		}
	}
}

#pragma mark -
#pragma mark Action sheet delegate methods

-(void)actionSheet:(UIActionSheet *)sheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *buttonTitle = [sheet buttonTitleAtIndex:buttonIndex];
	if( sheet.destructiveButtonIndex == buttonIndex ) {
		if( [buttonTitle isEqualToString:@"Unshare"] ) {
			typeLinkConnection = [[TypeLinkService currentService] unsharePage:page
                                                                      fromUser:shareToDelete
                                                                      delegate:self];
		} else {
			typeLinkConnection = [[TypeLinkService currentService] removeAlias:aliasToDelete
                                                                      fromPage:page
                                                                      delegate:self];
		}
	}
	// otherwise do nothing
}

#pragma mark -
#pragma mark Text field delegate methods

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder]; 
    return YES;
}

#pragma mark -
#pragma mark TypeLinkConnection delegate methods

-(void)createConnectionFinished:(TypeLinkConnection *)connection
					   withPage:(Page *)myPage
{
	self.navigationItem.rightBarButtonItem = saveButton;
	[delegate modalDismissAndUpdatePage:myPage];
}

-(void)saveConnectionFinished:(TypeLinkConnection *)connection
					 withPage:(Page *)myPage
{
	self.navigationItem.rightBarButtonItem = saveButton;
	[delegate modalDismissAndUpdatePage:myPage];
}

-(void)shareConnectionFinished:(TypeLinkConnection *)connection
{
	// add cell
	[page.sharedTo addObject:self.shareToAdd];
	
	// reload data
	[self.tableView reloadData];
}

-(void)unshareConnectionFinished:(TypeLinkConnection *)connection
{
	// remove cell
	[page.sharedTo removeObject:self.shareToDelete];
	
	// reload data
	[self.tableView reloadData];
}

-(void)addAliasConnectionFinished:(TypeLinkConnection *)connection
{
	// add cell
	[page.aliases addObject:self.aliasToAdd];
	
	// reload data
	[self.tableView reloadData];
}

-(void)removeAliasConnectionFinished:(TypeLinkConnection *)connection
{
	// remove cell
	[page.aliases removeObject:self.aliasToDelete];
	
	// reload data
	[self.tableView reloadData];
}

//-(void)fontsConnectionFinished:(TypeLinkConnection *)c
//					 withFonts:(NSArray *)f
//{
//	[Font setAllFonts:f];
//	NSLog(@"refreshing table");
//	//[tableView reloadData];
//    [tableView reloadSections:[NSIndexSet indexSetWithIndex:FONT_SECTION]
//             withRowAnimation:UITableViewRowAnimationTop];
//}

- (void)connectionFailed:(TypeLinkConnection *)connection
		  withStatusCode:(NSInteger)statusCode
				 message:(NSString *)message
{
	self.navigationItem.rightBarButtonItem = saveButton;
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
													message:message
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:@"OK",nil];
	[a show];
}

#pragma mark -
#pragma mark Button handlers

-(IBAction)cancel {
	[delegate modalDismiss];
}

-(IBAction)save {
	self.navigationItem.rightBarButtonItem = activityItem;
	
	self.page.title = self.titleField.text;
	self.page.publiclyVisible = self.publiclyVisible.on;
	
	// existing page - save
	if( prevTitle ) {
		NSLog(@"existing page - save");
		typeLinkConnection = [[TypeLinkService currentService] savePage:page
                                                              withTitle:prevTitle
                                                               delegate:self];
		// new page - create
	} else {
		NSLog(@"new page - create");
		self.page.content =
		[NSString stringWithFormat:@"Edit this page to describe %@ here.",
		 self.page.title];
		typeLinkConnection = [[TypeLinkService currentService] createPage:page
                                                                  forUser:user
                                                                 delegate:self];
	}
}

-(IBAction)textFieldReturn:(id)sender
{
	NSLog(@"textFieldReturn");
	[sender resignFirstResponder];
	NSLog(@"alert: %@", alert);
	
	[alert dismissWithClickedButtonIndex:1
								animated:YES];
	
	// not sure why that doesn't fire the event -- do it here instead
	NSString *shareUser = ((UITextField *)sender).text;
    typeLinkConnection = [[TypeLinkService currentService] sharePage:page
                                                              toUser:shareUser
                                                            delegate:self];	
	
}

-(void)updateFont:(Font *)font
{
    page.font = font;
    
    // always update font in settings cell
    [self.tableView reloadData];
    
    // only update font immediately on page if on iPad
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [delegate updateFont:font];
    }
}

@end
