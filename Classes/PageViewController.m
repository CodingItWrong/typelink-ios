//
//  PageViewController.m
//  TypeLinkNav
//
//  Created by Josh Justice on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PageViewController.h"
#import <Twitter/Twitter.h>
//#import <Social/Social.h>
//#import <Accounts/Accounts.h>

#import "EditPageViewController.h"
#import "Font.h"
#import "Page.h"
#import "Settings.h"
#import "TablePageSettingsViewController.h"
#import "TypeLinkService.h"
#import "UrlUtils.h"
#import "User.h"
#import "ProgressViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#define HOME_PAGE_TITLE @"Home"

@interface PageViewController()

-(void)navigateToPage:(NSString *)page;
-(void)pushPage:(NSString *)page forUser:(NSString *)pageUser;
-(void)displayCurrentPage;

-(void)reloadPage;
-(void)editPage;
-(void)editPageLoadDone;
-(void)showSettings;
-(void)sharePage;

-(void)disableButtons;
-(void)enableButtons;
-(void)showProgress;
-(void)hideProgress;

-(NSString *)pageJs;
-(NSString *)pageCss;

@end


@implementation PageViewController

@synthesize webView;
@synthesize webViewScroll;
@synthesize modal;
@synthesize editBtn;
@synthesize settingsBtn;
@synthesize shareBtn;
@synthesize deleteBtn;
@synthesize addBtn;
@synthesize activity;
@synthesize popover;
@synthesize progress;

@synthesize typeLinkConnection;
@synthesize user;
@synthesize page;
@synthesize pageTitle;
@synthesize editOnLoad;
@synthesize editingText;
@synthesize settings;

static NSString *pageJs = nil;
static NSString *pageMonospaceJs = nil;
static NSString *pageCss = nil;

-(NSString *)pageJs {
	if( nil == pageJs ) {
		NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"TypeLink" ofType:@"js"];
		NSData *jsData = [NSData dataWithContentsOfFile:jsPath];  
		pageJs = [[NSString alloc] initWithData:jsData
									   encoding:NSASCIIStringEncoding];
	}
	return pageJs;
}

-(NSString *)pageMonospaceJs {
	if( nil == pageMonospaceJs ) {
		NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"ios-monospace-fix" ofType:@"js"];
		NSData *jsData = [NSData dataWithContentsOfFile:jsPath];  
		pageMonospaceJs = [[NSString alloc] initWithData:jsData
												encoding:NSASCIIStringEncoding];
	}
	return pageMonospaceJs;
}

-(NSString *)pageCss {
	if( nil == pageCss ) {
		NSString *cssPath = [[NSBundle mainBundle] pathForResource:@"TypeLink" 
															ofType:@"css"];
		NSData *cssData = [NSData dataWithContentsOfFile:cssPath];  
		pageCss = [[NSString alloc] initWithData:cssData
										encoding:NSASCIIStringEncoding];
	}
	return pageCss;
}

-(id)initWithUser:(NSString *)u
			 page:(NSString *)p
		 settings:(Settings *)set {
	if( ( self = [self initWithNibName:@"PageViewController"
							  bundle:[NSBundle mainBundle]] ) )
	{
		self.user = u;
		self.settings = set;
		self.pageTitle = p;
		
		self.title = self.pageTitle; // ui
		
		UIBarButtonItem *homeBtn =
		[[UIBarButtonItem alloc] initWithTitle:@"Home"
										 style:UIBarButtonItemStylePlain
										target:self
										action:@selector(goToHome)];
		UIBarButtonItem *myEditBtn =
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
													  target:self
													  action:@selector(editPage)];
		self.editBtn = myEditBtn;
		UIImage *settingsImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"19-gear" ofType:@"png"]];
		UIBarButtonItem *mySettingsBtn =
		[[UIBarButtonItem alloc] initWithImage:settingsImage
										 style:UIBarButtonItemStylePlain
										target:self
										action:@selector(showSettings)];
		self.settingsBtn = mySettingsBtn;
		UIBarButtonItem *sp =
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
													  target:nil
													  action:nil];
		UIBarButtonItem *myShareBtn =
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
													  target:self
													  action:@selector(sharePage)];
		self.shareBtn = myShareBtn;
		UIBarButtonItem *myDeleteBtn =
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
													  target:self
													  action:@selector(deletePage)];
		self.deleteBtn = myDeleteBtn;

		UIBarButtonItem *myAddBtn =
		 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
													   target:self
													   action:@selector(newPage)];
		self.addBtn = myAddBtn;
		

		CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);  
		UIActivityIndicatorView *myActivity = 
		[[UIActivityIndicatorView alloc] initWithFrame:frame];
		[myActivity sizeToFit];
		myActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);  
		self.activity = [[UIBarButtonItem alloc] initWithCustomView:myActivity];
		
		self.navigationItem.rightBarButtonItem = homeBtn;
		
		NSArray *toolbarItems;
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			// iPad: items aligned to left and right
			toolbarItems
			= [NSArray arrayWithObjects:
			   editBtn,settingsBtn,sp,shareBtn,deleteBtn,addBtn,nil];
		} else {
			// iPhone: evenly spaced toolbar items
			toolbarItems
			= [NSArray arrayWithObjects:
			   editBtn,sp,settingsBtn,sp,shareBtn,sp,deleteBtn,sp,addBtn,nil];
		}
		self.toolbarItems = toolbarItems;
		
		[self disableButtons];
	}
	return self;
}

#pragma mark -
#pragma mark Business logic methods

- (void)navigateToPage:(NSString *)newPageTitle {
	self.pageTitle = newPageTitle;
	[self reloadPage];
}

- (void)reloadPage {
	[self disableButtons];
	[self showProgress];
	if( nil == [User currentUser] ) {
		typeLinkConnection = [[TypeLinkService currentService] getAccountWithDelegate:self];
		// will then call getPageForUser...
	} else {
		typeLinkConnection = [[TypeLinkService currentService] getPageForUser:user
                                                                    withTitle:self.pageTitle
                                                                     delegate:self];
	}
}

- (void)connectionFailed:(TypeLinkConnection *)connection
		  withStatusCode:(NSInteger)statusCode
				 message:(NSString *)message
{
    NSString *title = @"Error";
    UIAlertView *alert;
    
	[self enableButtons];
	[self hideProgress];
	
    NSLog(@"message length = %d", (int)[message length]);
    
	if( statusCode == 403 ) {
		NSLog(@"Access error - could prompt for un/pw");
	} else if( statusCode == 0 ) {
		message = @"Could not connect to TypeLink server. Please make sure you're connected to the internet and try again.";
	} else if( !message || [message length] < 6
              || [[message substringToIndex:6] isEqualToString:@"<html>"] )
    {
		message = @"A server error occurred. Please try again.";
	}
    
    if( NSNotFound != [message rangeOfString:@"Pro account"].location ) {
        title = @"Page Limit Reached";
        /*
        message = @"Thank you for trying TypeLink! You have reached the max number of pages you can create with a Basic account.";
        alert = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        */
        alert = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:@"Not Now"
                                 otherButtonTitles:@"Upgrade",nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"OK",nil];
    }
    
	[alert show];
}

-(void)accountConnectionFinished:(TypeLinkConnection *)connection
						withUser:(User *)u
{
	[User setCurrentUser:u];
	typeLinkConnection = [[TypeLinkService currentService] getPageForUser:self.user
                                                                withTitle:self.pageTitle
                                                                 delegate:self];
}

-(void)getConnectionFinished:(TypeLinkConnection *)connection
					withPage:(Page *)fullPage
{
	self.page = fullPage;
	
	[self displayCurrentPage];
	
	// one time check of editingText -- display edit panel if set
	if( editingText || editOnLoad ) {
		[self editPageLoadDone];
		editingText = nil;
		editOnLoad = NO;
	}
}

- (void)pushPage:(NSString *)pageName
		 forUser:(NSString *)pageUser
{
	NSLog(@"pageName = %@", pageName);
	PageViewController *pageViewController =
	[[PageViewController alloc] initWithUser:pageUser
										page:pageName
									settings:settings];
	[self.navigationController pushViewController:pageViewController animated:YES];
}

- (void)displayCurrentPage {
	self.title = page.title;
	
	// load wiki content
	NSString *wikiContent = page.wikiContent;
	if( nil == wikiContent ) {
		wikiContent = @"";
	}
	
	// dynamic css
	Font *font = page.font;
	if( nil == font ) {
		font = [User currentUser].defaultFont;
	}
    float size = (int)( 16.0 * [[Settings currentSettings].fontSize floatValue] );
	NSString *cssString2 =
        [NSString stringWithFormat:@"body{font-family:%@;font-size:%fpx}",
							font.cssCode, size];
	NSLog(@"css: %@", cssString2);
	// load js
	NSString *jsString2 = @"";
	
	// only include monospace fix if courier new
	if( [font.name isEqualToString:@"Courier New"] ) {
		jsString2 = [self pageMonospaceJs];
	}
	
	// headers
	NSString *headers = [NSString stringWithFormat:@"<base href='%@%@/'/><meta name='viewport' content='initial-scale=1.0,maximum-scale=10.0'/>",
						 WEB_URL, // found in project build settings, Preprocessor Macros
						 page.user];
	
	// compose full html page
	NSString *pageContent =
	[NSString stringWithFormat:@"<html><head><style type='text/css'>%@ %@</style><script language='javascript'>%@ %@</script>%@</head><body>%@</body></html>",
	 [self pageCss], cssString2,
	 [self pageJs], jsString2,
	 headers, wikiContent];
	
	// display
	self.webViewScroll = [[webView stringByEvaluatingJavaScriptFromString:@"scrollY"] intValue];
	[webView loadHTMLString:pageContent baseURL:nil];
	// scroll reset by webViewDidFinishLoading
}

- (void)goToHome {
	id rootViewController = [[self.navigationController viewControllers] objectAtIndex:0];
	PageViewController *pageViewController =
	[[PageViewController alloc] initWithUser:settings.username
										page:@"Home"
									settings:settings];
	[self.navigationController setViewControllers:
	 [NSArray arrayWithObjects: rootViewController, pageViewController, nil]
										 animated:NO];
}

- (void)disableButtons {
	self.editBtn.enabled = NO;
	self.settingsBtn.enabled = NO;
	self.shareBtn.enabled = NO;
	self.deleteBtn.enabled = NO;	
	self.addBtn.enabled = NO;
}

- (void)enableButtons {
	self.editBtn.enabled = [page isEditableBy:settings.username];
	self.settingsBtn.enabled = [settings.username isEqualToString:page.user];
	self.shareBtn.enabled = [page publiclyVisible];
	self.deleteBtn.enabled =
		[settings.username isEqualToString:page.user]
		&& ![self.page.title isEqualToString:HOME_PAGE_TITLE];
	self.addBtn.enabled = YES;
}

- (void)showProgress {
	progress.view.frame = self.view.frame;
	[self.view addSubview:progress.view];
    [progress.activity startAnimating];
}

- (void)hideProgress {
	[progress.view removeFromSuperview];
    [progress.activity stopAnimating];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
			navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = request.URL;
	NSLog(@"url: %@", [url absoluteString]);
	
	// events from js
	if( [[url scheme] isEqual:@"typelink"]) {
		// events from JS
		if([[url host] isEqualToString:@"doubleTap"]) {
			if( [page isEditableBy:settings.username] ) {
				[self editPage];
			}
		}
		return NO;
		
	// log statements from js
	} else if ([[url scheme] isEqualToString:@"log"]) {
		return NO; // do nothing--already logged
		
	// opening new page window--still blank
	} else if ([[url scheme] isEqual:@"about"]) {
		return YES;
		
	// embedded youtube player
	} else if( [[url host] isEqualToString:@"www.youtube.com"] ) {
		return YES;
		
	// tapped a wiki page link
	} else if( [[url host] isEqualToString:WEB_HOST] ) {; // found in project build settings, Preprocessor Macros
		//NSString *encodedName = [[url relativePath] substringFromIndex:1];
		NSString *relativePath = [[url absoluteString] substringFromIndex:[WEB_URL length]];
		NSInteger slashIndex = [relativePath rangeOfString:@"/"].location;
		NSString *userName = [relativePath substringToIndex:slashIndex];
		NSLog(@"userName = %@", userName);
		NSString *encodedName = [relativePath substringFromIndex:slashIndex+1];
		
		NSString *pageName =
		[[encodedName
		  stringByReplacingOccurrencesOfString:@"+"
									withString:@" "]
		  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[self pushPage:pageName forUser:userName];
		return NO;
	} // else {
	
	// open all other urls in safari
	[[UIApplication sharedApplication] openURL:request.URL];
	return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
	[webView stringByEvaluatingJavaScriptFromString:
	 [NSString stringWithFormat:@"window.scrollTo(0, %d);", (int)self.webViewScroll]];
	[self enableButtons];
	[self hideProgress];
}

#pragma mark -
#pragma mark Button handlers

- (void)newPage {
	
	// default page name is selection
	NSString *defaultPageName = [webView stringByEvaluatingJavaScriptFromString:@"getSel()"];
	
	// if no selection, page name is clipboard
	/* don't want to use since auto create page
	if([defaultPageName isEqualToString:@""]) {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		defaultPageName = pasteboard.string;
		NSLog(@"pasteboard: %@", defaultPageName);
	}
	 */
	
	if( [defaultPageName isEqualToString:@""] ) {
		NSString *msg = @"To create a new page, type its name on this page, then select it and tap +. For more info, tap \"Help me\".";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Page"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Help me",nil];
		[alert show];
		/*
		BOOL isPopover = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
		TablePageSettingsViewController *c
		= [[TablePageSettingsViewController alloc] initWithUser:settings.username
													   pageName:defaultPageName
													   delegate:self
														service:service
														popover:isPopover];
		self.modal = c;

		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			if( [popover isPopoverVisible] ) {
				[popover dismissPopoverAnimated:YES];
			}
			c.contentSizeForViewInPopover = CGSizeMake(300.0f, 150.0f);
			UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:c];
			[p presentPopoverFromBarButtonItem:addBtn
					  permittedArrowDirections:UIPopoverArrowDirectionAny
									  animated:YES];
			self.popover = p;
			[p release];
		} else {
			[self presentModalViewController:c animated:YES];
			self.modal = c;
		}
		
		[c release];
		 */
    } else if ( NSNotFound != ([defaultPageName rangeOfString:@"/"]).location ) {
		NSString *msg = @"Page names may not contain slashes.";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Page"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
		[alert show];
	} else {
		Page *p = [[Page alloc] init];
		p.title = defaultPageName;
		p.publiclyVisible = NO;
		p.content = [NSString stringWithFormat:@"Edit this page to describe %@ here.",
					 defaultPageName];
		
        [self disableButtons];
		[self showProgress];
		typeLinkConnection = [[TypeLinkService currentService] createPage:p
                                                                  forUser:settings.username
                                                                 delegate:self];
	}
}

-(void)createConnectionFinished:(TypeLinkConnection *)connection
					   withPage:(Page *)fullPage
{
    [self enableButtons];
	[self hideProgress];
	[self pushPage:fullPage.title forUser:settings.username];
}

- (void)editPage {
	self.editOnLoad = YES;
	[self reloadPage];
}

- (void)editPageLoadDone {
//	self.title = self.page.title;
	
	EditPageViewController *c;
	if( editingText ) {
		c =
		[[EditPageViewController alloc] initWithPage:page
												text:editingText
											delegate:self];
	} else {
		c =
		[[EditPageViewController alloc] initWithPage:page
											delegate:self];
	}
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:c];
    [self presentViewController:nc animated:YES completion:nil];
	
	// start ipad
	if( [popover isPopoverVisible] ) {
		[popover dismissPopoverAnimated:YES];
	}
	// end ipad
	
	self.modal = c;
}

- (void)deletePage {
	UIActionSheet *alert =
	[[UIActionSheet alloc] initWithTitle:@"Delete this page?"
								delegate:self
					   cancelButtonTitle:@"Cancel"
				  destructiveButtonTitle:@"Delete"
					   otherButtonTitles:nil];
    [alert showFromBarButtonItem:deleteBtn
                        animated:YES];
}

- (void)showSettings {
	self.title = self.page.title;
	
	BOOL isPopover = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	TablePageSettingsViewController *c = 
	[[TablePageSettingsViewController alloc] initWithPage:page
												 delegate:self
												  popover:isPopover];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:c];
    
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if( [popover isPopoverVisible] ) {
			[popover dismissPopoverAnimated:YES];
		}
		c.preferredContentSize = CGSizeMake(300.0f, 550.0f);
		UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:nc];
		[p presentPopoverFromBarButtonItem:settingsBtn
				  permittedArrowDirections:UIPopoverArrowDirectionAny
								  animated:YES];
		self.popover = p;
	} else {
        [self presentViewController:nc animated:YES completion:nil];
		self.modal = nc;
	}
}

- (void)sharePage {
  
    NSString *pageUrlString = [NSString stringWithFormat:@"http://typelink.net/%@/%@",
                               page.user,[UrlUtils urlEncode:page.title]];
    NSURL *pageUrl = [NSURL URLWithString:pageUrlString];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[pageUrl]
                                                                     applicationActivities:nil];
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if( [popover isPopoverVisible] ) {
            [popover dismissPopoverAnimated:YES];
        }
//        nc.contentSizeForViewInPopover = CGSizeMake(300.0f, 335.0f);
//        c.contentSizeForViewInPopover = CGSizeMake(300.0f, 335.0f);
        UIPopoverController *p = [[UIPopoverController alloc] initWithContentViewController:vc];
        [p presentPopoverFromBarButtonItem:self.shareBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:vc animated:YES completion:nil];
    }
    
//	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Share Page"
//													   delegate:self
//											  cancelButtonTitle:@"Cancel"
//										 destructiveButtonTitle:nil
//											  otherButtonTitles:@"Copy Link", @"E-mail", @"Twitter", @"Facebook", nil];
//	[sheet showFromBarButtonItem:shareBtn animated:YES];
}

#pragma mark -
#pragma mark Modal callbacks

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)i
{
    NSLog(@"alertView dismiss");
	if( i != [alert cancelButtonIndex] ) {
        if( [alert.title isEqualToString:@"New Page"]) {
            NSURL *url = [NSURL URLWithString:@"http://typelink.net/help-ios/Creating+a+page"];
            [[UIApplication sharedApplication] openURL:url];
        } else {
            NSString *urlString = [NSString stringWithFormat:@"%@account/subscribe", WEB_URL];
            NSLog(@"url: %@", urlString);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
	}
}

- (void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(NSInteger)i
{
	if( [sheet.title isEqualToString:@"Delete this page?"] ) {
		if( i == [sheet destructiveButtonIndex] ) {
			[self showProgress];
			typeLinkConnection = [[TypeLinkService currentService] deletePageForUser:user
                                                                           withTitle:self.title
                                                                            delegate:self];
		}
	}
}

-(void)deleteConnectionFinished:(TypeLinkConnection *)connection {
	[self.navigationController popViewControllerAnimated:YES];
	[self hideProgress];
}

- (void)modalDismissAndUpdatePage:(Page *)p {
	BOOL animate = YES;
	// if creating a new page, navigate to it
	if( [self.modal isMemberOfClass:[TablePageSettingsViewController class]]
	   && nil != ((TablePageSettingsViewController *)self.modal).user )
	{
		[self pushPage:p.title forUser:settings.username];
		
	// if editing this page's settings, redisplay it
	} else {
		self.page = p;
		self.pageTitle = p.title;
		self.title = page.title;
		[self displayCurrentPage]; // in case font changed
		
		// animate settings, but not edit
		if( ![self.modal isMemberOfClass:[TablePageSettingsViewController class]] ) {
			animate = NO;
		}
	}
	
	self.modal = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
	if( self.popover ) {
		if( [popover isPopoverVisible] ) {
			[popover dismissPopoverAnimated:YES];
		}
	}
}

- (void)modalDismiss {
	//BOOL animate = [self.modal isMemberOfClass:[TablePageSettingsViewController class]];
    [self dismissViewControllerAnimated:YES completion:nil];
	
	self.modal = nil;
}

- (void)updateFont:(Font *)font {
	[self displayCurrentPage];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Superclass method overrides

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	webView.delegate = self;
    webView.scalesPageToFit = YES;
	
	ProgressViewController *c = [[ProgressViewController alloc] initWithNibName:@"ProgressViewController"
																		 bundle:[NSBundle mainBundle]];
	self.progress = c;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
		|| interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self displayCurrentPage]; // to fix width
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if( nil == modal ) {
		// redisplaying from a back -- reload
		[self reloadPage];
	}
	// modal close methods handle their redisplaying separately
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
