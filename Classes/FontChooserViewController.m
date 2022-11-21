//
//  FontChooserViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FontChooserViewController.h"
#import "Font.h"
#import "ModalDelegate.h"
#import "TypeLinkConnection.h"
#import "TypeLinkService.h"
#import "User.h"

@implementation FontChooserViewController

@synthesize selectedFont;
@synthesize allowDefault;
@synthesize delegate;
@synthesize typeLinkConnection;

-(id)initWithFont:(Font *)f
     allowDefault:(BOOL)ad
		 delegate:(id <ModalDelegate>)d
{
	if( ( self = [self initWithNibName:@"FontChooserViewController"
							  bundle:[NSBundle mainBundle]] ) )
	{
        self.selectedFont = f;
        self.allowDefault = ad;
        self.delegate = d;
        
        self.navigationItem.title = @"Font";
        
		if( nil == [Font allFonts] ) {
			NSLog(@"all fonts are nil");
			typeLinkConnection = [[TypeLinkService currentService] getFontsWithDelegate:self];
		} else { 
			NSLog(@"all fonts are not nil: %@", [Font allFonts]);
		}
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( nil == [Font allFonts] ) {
        return 0;
    } else {
        return [[Font allFonts] count]+( allowDefault ? 1 : 0 );
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.textColor = [UIColor blackColor];
    if( allowDefault && 0 == indexPath.row ) {
        cell.textLabel.text = @"Use default";
        UIFont *myFont = [UIFont fontWithName:[User currentUser].defaultFont.iOSCode size:16.0f];
        if( myFont ) {
            cell.textLabel.font = myFont;
        }
        cell.accessoryView = nil;
        if( nil == selectedFont ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        NSArray *fonts = [Font allFonts];
        NSInteger idx = indexPath.row - ( allowDefault ? 1 : 0 );
        Font *font = [fonts objectAtIndex:idx];
        cell.textLabel.text = font.name;
        UIFont *myFont = [UIFont fontWithName:font.iOSCode size:16.0f];
        if( myFont ) {
            cell.textLabel.font = myFont;
        }
        cell.accessoryView = nil;
        if( [selectedFont.name isEqualToString:font.name] ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
	
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *loopIndexPath;
    UITableViewCell *cell;
    for( int i = 0; i <= [[Font allFonts] count]; i++ ) {
        NSUInteger indexArr[] = { 0, i };
        loopIndexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
        cell = [tableView cellForRowAtIndexPath:loopIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if( allowDefault && 0 == indexPath.row ) {
        selectedFont = nil;
    } else {
        selectedFont = [[Font allFonts] objectAtIndex:indexPath.row - ( allowDefault ? 1 : 0 ) ];
    }
    [delegate updateFont:selectedFont];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TypeLink methods

-(void)fontsConnectionFinished:(TypeLinkConnection *)c
					 withFonts:(NSArray *)f
{
	[Font setAllFonts:f];
	NSLog(@"refreshing table");
	//[tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
             withRowAnimation:UITableViewRowAnimationTop];
}

- (void)connectionFailed:(TypeLinkConnection *)connection
		  withStatusCode:(NSInteger)statusCode
				 message:(NSString *)message
{
//	navBar.topItem.rightBarButtonItem = saveButton;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:message
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:@"OK",nil];
	[alert show];
}

@end
