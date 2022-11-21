//
//  FontChooserViewController.m
//  TypeLinkData
//
//  Created by Josh Justice on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FontSizeChooserViewController.h"
#import "Font.h"
#import "ModalDelegate.h"
#import "TypeLinkConnection.h"
#import "TypeLinkService.h"
#import "User.h"

@implementation FontSizeChooserViewController

@synthesize selectedSize;
@synthesize delegate;
@synthesize sizeOptions;

-(id)initWithSize:(float)s
		 delegate:(id <ModalDelegate>)d
{
	if( ( self = [self initWithNibName:@"FontSizeChooserViewController"
                                bundle:[NSBundle mainBundle]] ) )
	{
        self.selectedSize = s;
        self.delegate = d;
        
        self.navigationItem.title = @"Font Size";
        
        // size options
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"Config.plist"];
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        self.sizeOptions = [config objectForKey:@"FontSizeOptions"];
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
    return [sizeOptions count];
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
    NSInteger i = indexPath.row;
    int sizePct = 100.0 * [[sizeOptions objectAtIndex:i] floatValue];
    cell.textLabel.text = [NSString stringWithFormat:@"%d%%", sizePct];
    if( selectedSize == [[sizeOptions objectAtIndex:i] floatValue] ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    selectedSize = [[sizeOptions objectAtIndex:indexPath.row] floatValue];
    [delegate updateFontSize:selectedSize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
