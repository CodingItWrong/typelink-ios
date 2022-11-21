//
//  TypeLinkDataAppDelegate.m
//  TypeLinkData
//
//  Created by Josh Justice on 10/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TypeLinkDataAppDelegate.h"

#import "AlertService.h"
#import "AlertConnection.h"
#import "EditPageViewController.h"
#import "RootViewController.h"
#import "PageViewController.h"
#import "Page.h"
#import "Settings.h"
#import "TypeLinkService.h"
#import "LockScreenViewController.h"

#define NAV_PATH_KEY @"NavPath"
#define EDITING_TEXT_KEY @"EditingText"
#define EDITING_TITLE_KEY @"EditingTitle"

#define USER_KEY @"user"
#define TITLE_KEY @"title"

@interface TypeLinkDataAppDelegate()
-(NSDictionary *)loadConfig;
-(Settings *)loadSettingsWithConfig:(NSDictionary *)config;
-(void)restoreNavForSettings:(Settings *)settings
					 service:(TypeLinkService *)service;
-(void)showAlerts;
-(void)saveState;
-(void)checkForShowingLockScreen;
@end

@implementation TypeLinkDataAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize alertService;
@synthesize alertConnection;
@synthesize settings;

@synthesize launchUrl;

#pragma mark -
#pragma mark Business logic

-(void)showAlerts {
	alertConnection = [alertService getAlertsWithDelegate:self];
}

-(void)connectionFailed:(TypeLinkConnection *)connection
		 withStatusCode:(NSInteger)statusCode
				message:(NSString *)message
{
	; // do nothing if can't get alerts
}

-(void)alertConnectionFinished:(TypeLinkConnection *)connection
					withAlerts:(NSArray *)alerts
{
	if( alerts && [alerts count] > 0 ) {
		UIAlertView *alert =
		[[UIAlertView alloc] initWithTitle:@"Alert"
								   message:[alerts objectAtIndex:0]
								  delegate:self
						 cancelButtonTitle:nil
						 otherButtonTitles:@"OK", nil];
		[alert show];
	}
}

-(void)saveState
{
	// save nav path
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *vcs = [navigationController viewControllers];
	NSMutableArray *navPath = [[NSMutableArray alloc] initWithCapacity:[vcs count]];
	NSEnumerator *myEnum = [vcs objectEnumerator];
	UIViewController *vc;
	NSDictionary *pageToSave;
	PageViewController *pvc;
	while( ( vc = [myEnum nextObject] ) ) {
		if( [vc isMemberOfClass:[PageViewController class]] ) {
			pvc = (PageViewController *)vc;
			if( nil != pvc.pageTitle ) {
				pageToSave = [NSDictionary dictionaryWithObjectsAndKeys:pvc.user, USER_KEY, pvc.title, TITLE_KEY, nil];
				NSLog(@"page = %@", pageToSave);
				[navPath addObject:pageToSave];
			}
			NSLog(@"pvc.modal: %@", pvc.modal);
			if( pvc.modal && [pvc.modal isMemberOfClass:[EditPageViewController class]] ) {
				EditPageViewController *epvc = (EditPageViewController *)pvc.modal;
				if( epvc.changed ) {
					NSLog(@"currently editing %@: %@", epvc.page.title, epvc.textView.text);
					[defaults setObject:epvc.page.title forKey:EDITING_TITLE_KEY];
					[defaults setObject:epvc.textView.text forKey:EDITING_TEXT_KEY];
				}
			} else {
				NSLog(@"not currently editing");
			}
		}
	}
	NSLog(@"Storing nav path %@", navPath);
	[defaults setObject:navPath forKey:NAV_PATH_KEY];
	
}

-(void)checkForShowingLockScreen {
    if( (YES == [settings.lock boolValue]) && (![settings.password isEqualToString:@""]) ) {
        UIViewController<ModalDelegate> *del = (UIViewController<ModalDelegate> *)[navigationController topViewController];
        if( nil != del.presentedViewController ) {
            // have to hide existing modal to show new one
            // state of page edit should be saved prev to this
            [del dismissViewControllerAnimated:NO completion:nil];
        }
        LockScreenViewController *lsvc =
        [[LockScreenViewController alloc] initWithSettings:settings
                                                  delegate:del];
        [navigationController presentViewController:lsvc animated:NO completion:nil];
    }
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
	NSLog(@"got launch url");
	self.launchUrl = url; // process when loading page
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[launchUrl absoluteString]
													message:@"the launch url"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
    
    return true;
}

- (void)awakeFromNib {    
    [super awakeFromNib];
    
    RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    NSLog(@"application:didFinishLaunchingWithOptions");
    
    // Override point for customization after application launch.
	NSDictionary *config = [self loadConfig];
	Settings *mySettings = [self loadSettingsWithConfig:config];
    self.settings = mySettings;
	
	//NSString *apiUrl = [config objectForKey:@"RestApiUrl"];
	NSString *apiUrl = API_URL; // found in project build settings, Preprocessor Macros
	NSLog(@"api url: %@", apiUrl);
	
	TypeLinkService *service = [[TypeLinkService alloc] initWithApiUrl:apiUrl
															  settings:settings];
	[TypeLinkService setCurrentService:service];
    RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
	rootViewController.settings = settings;
	
	AlertService *myAlertService = [[AlertService alloc] initWithApiUrl:apiUrl];
	self.alertService = myAlertService;
	
	// no idea why this code has to go here or won't work
	rootViewController.navigationItem.title = @"My Pages";
	[rootViewController setUpToolbar];
	// end no idea
	
	[self restoreNavForSettings:settings service:service];
	
    // Add the navigation controller's view to the window and display.
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
	
    [self checkForShowingLockScreen];
	[self showAlerts];
    
    return YES;
}

-(void)restoreNavForSettings:(Settings *)mySettings
					 service:(TypeLinkService *)service
{
	NSLog(@"restore nav");
	
	// check user defaults
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	NSArray *navPath = [d arrayForKey:NAV_PATH_KEY];
	if( nil == navPath ) {
		navPath = [NSArray arrayWithObject:@"Home"];
		NSLog(@"setting default nav path %@", navPath);
	} else {
		NSLog(@"using loaded nav path %@", navPath);
	}
	
	// recreate views 
	NSMutableArray *myViewControllers = [[NSMutableArray alloc] initWithCapacity:1+[navPath count]];
    RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
	[myViewControllers addObject:rootViewController];
	
	NSEnumerator *myEnum = [navPath objectEnumerator];
	NSDictionary *loadedPage;
	PageViewController *pageViewController;
    NSString *title;
	while( ( loadedPage = [myEnum nextObject] ) ) {
		NSLog(@"loaded a page: %@", [loadedPage class]);
		if( [loadedPage isKindOfClass:[NSDictionary class]] ) {
            title = [loadedPage objectForKey:TITLE_KEY];
			pageViewController =
			[[PageViewController alloc] initWithUser:[loadedPage objectForKey:USER_KEY]
												page:title
											settings:mySettings];
			[myViewControllers addObject:pageViewController];
		}
	}
	
	// open editing popup if was left open
	NSString *editingTitle = [d stringForKey:EDITING_TITLE_KEY];
	[d removeObjectForKey:EDITING_TITLE_KEY];
	NSString *editingText = [d stringForKey:EDITING_TEXT_KEY];
	[d removeObjectForKey:EDITING_TEXT_KEY];
	if( editingTitle && editingText ) {
        if( [editingTitle isEqualToString:title] ) {
            NSLog(@"restoring saved editing text: %@", editingText );
            pageViewController.editingText = editingText;
            // controller will use this to open edit window when ready
        } else {
            NSLog(@"Navigated to another page--not restoring unsaved text");
        }
	}
	
	[self.navigationController setViewControllers:myViewControllers
										 animated:NO];
}

-(NSDictionary *)loadConfig {
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:@"Config.plist"];
	return [NSDictionary dictionaryWithContentsOfFile:finalPath];
}

-(Settings *)loadSettingsWithConfig:(NSDictionary *)config {
	Settings *mySettings = nil;
	NSError *error;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings"
											  inManagedObjectContext:managedObjectContext_];
	[request setEntity:entity];
	NSMutableArray *mutableFetchResults = [[managedObjectContext_ executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// TODO Handle the error.
		NSLog(@"Settings load failed");
	} else if( [mutableFetchResults count] > 0 ) {
		if( [mutableFetchResults count] > 2 ) {
			NSLog(@"Warning: more than one settings found");
		} else {
			NSLog(@"One settings file found.");
		}
		mySettings = [mutableFetchResults objectAtIndex:0];
	} else {
		NSLog(@"New settings");
		// new settings
		mySettings = (Settings *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings"
																		 inManagedObjectContext:managedObjectContext_];
		mySettings.username = [config objectForKey:@"DefaultUsername"];
		mySettings.password = [config objectForKey:@"DefaultPassword"];
        mySettings.fontSize = [config objectForKey:@"DefaultFontSize"];
        // mySettings.lock = NO; // this ends up as nil somehow -- 0, correct default, already set
		
		if(![managedObjectContext_ save:&error]) {
			// TODO: handle error
			NSLog(@"Error saving settings");
		}
	}
    [Settings setCurrentSettings:mySettings];
	return mySettings; // should not be reached
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self saveState]; // for multitasking enabled
	
    [self checkForShowingLockScreen];
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}

/*
- (void)applicationWillEnterForeground:(UIApplication *)application {
	[self showAlerts];
}
 */


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    
    // restored from background, so remove record of unsaved text
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d removeObjectForKey:EDITING_TEXT_KEY];

    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveState]; // for multitasking not enabled
	
	// save managed objects
    [self saveContext];
}


- (void)saveContext {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */

			NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
			NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
			if(detailedErrors != nil && [detailedErrors count] > 0) {
				for(NSError* detailedError in detailedErrors) {
					NSLog(@"  DetailedError: %@", [detailedError userInfo]);
				}
			}
			else {
				NSLog(@"  %@", [error userInfo]);
			}
            
			abort();
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"TypeLinkData" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"TypeLinkData.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end

