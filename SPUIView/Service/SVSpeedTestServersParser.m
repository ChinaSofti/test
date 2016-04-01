//
//  SVSpeedTestServersParser.m
//  SpeedPro
//
//  Created by Rain on 3/11/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVLog.h"
#import "SVSpeedTestServer.h"
#import "SVSpeedTestServersParser.h"

@implementation SVSpeedTestServersParser
{
    NSData *_data;
    NSMutableArray *_array;
}

@synthesize clientIP, isp, lat, lon;

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    _data = data;
    _array = [[NSMutableArray alloc] init];
    return self;
}

- (NSArray *)parse
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_data];
    parser.delegate = self;
    [parser parse];
    return _array;
}


//几个代理方法的实现，是按逻辑上的顺序排列的，但实际调用过程中中间三个可能因为循环等问题乱掉顺序
//开始解析
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    SVInfo (@"parserDidStartDocument...");
}

//准备节点
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(nullable NSString *)namespaceURI
  qualifiedName:(nullable NSString *)qName
     attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
    if ([elementName isEqualToString:@"client"])
    {
        clientIP = [attributeDict objectForKey:@"ip"];
        isp = [attributeDict objectForKey:@"isp"];
        lat = [attributeDict objectForKey:@"lat"];
        lon = [attributeDict objectForKey:@"lon"];
    }
    if ([elementName isEqualToString:@"server"])
    {
        NSString *url = [attributeDict objectForKey:@"url"];
        NSString *lat1 = [attributeDict objectForKey:@"lat"];
        NSString *lon1 = [attributeDict objectForKey:@"lon"];
        NSString *name = [attributeDict objectForKey:@"name"];
        NSString *sponsor = [attributeDict objectForKey:@"sponsor"];
        NSString *serverId = [attributeDict objectForKey:@"id"];

        SVSpeedTestServer *server = [[SVSpeedTestServer alloc] init];
        [server setServerId:[serverId intValue]];
        [server setServerURL:url];
        [server setLat:[lat1 floatValue]];
        [server setLon:[lon1 floatValue]];
        [server setName:name];
        [server setSponsor:sponsor];
        [_array addObject:server];
    }
}

//解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    SVInfo (@"parserDidEndDocument...");
}
@end
