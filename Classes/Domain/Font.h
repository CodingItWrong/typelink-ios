//
//  Font.h
//  TypeLinkData
//
//  Created by Josh Justice on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Font : NSObject {
	int fontId;
	NSString *name;
	NSString *iOSCode;
	NSString *cssCode;
}

@property (nonatomic,assign) int fontId;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *iOSCode;
@property (nonatomic,retain) NSString *cssCode;

+(Font *)fontFromDict:(NSMutableDictionary *)dict;

-(NSMutableDictionary *)asDict;

+(NSArray *)allFonts;

+(void)setAllFonts:(NSArray *)f;


@end
