//
//  SVSpeedTestServersParser.h
//  SpeedPro
//
//  Created by Rain on 3/11/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVSpeedTestServersParser : NSObject <NSXMLParserDelegate>

- (id)initWithData:(NSData *)data;

- (NSArray *)parse;

@end
