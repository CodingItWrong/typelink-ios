//
//  Settings.h
//  TypeLinkData
//
//  Created by Josh Justice on 7/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * lock;
@property (nonatomic, retain) NSNumber * fontSize;

+(Settings *)currentSettings;
+(void)setCurrentSettings:(Settings *)settings;

@end
