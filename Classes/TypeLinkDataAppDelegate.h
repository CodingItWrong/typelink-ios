//
//  TypeLinkDataAppDelegate.h
//  TypeLinkData
//
//  Created by Josh Justice on 10/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class AlertService;
@class AlertConnection;
@class Settings;

@interface TypeLinkDataAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	AlertService *alertService;
    AlertConnection *alertConnection;
    Settings *settings;
	
	NSURL *launchUrl;

@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) AlertService *alertService;
@property (nonatomic, retain) AlertConnection *alertConnection;
@property (nonatomic, retain) Settings *settings;

@property (nonatomic, retain) NSURL *launchUrl;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;

@end

