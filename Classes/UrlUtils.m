//
//  UrlUtils.m
//  TypeLinkData
//
//  Created by Josh Justice on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UrlUtils.h"


@implementation UrlUtils

+(NSString *)urlEncode:(NSString *)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}


@end
