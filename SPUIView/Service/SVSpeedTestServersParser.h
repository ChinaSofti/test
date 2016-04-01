//
//  SVSpeedTestServersParser.h
//  SpeedPro
//
//  Created by Rain on 3/11/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVSpeedTestServers.h"
#import <Foundation/Foundation.h>

@interface SVSpeedTestServersParser : NSObject <NSXMLParserDelegate>

@property NSString *clientIP;
@property NSString *isp;
@property NSString *lat;
@property NSString *lon;

- (id)initWithData:(NSData *)data;

- (NSArray *)parse;

@end
