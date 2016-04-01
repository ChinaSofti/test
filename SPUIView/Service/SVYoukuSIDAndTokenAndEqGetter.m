//
//  TSYoukuSIDAndTokenAndEqGetter.m
//  TaskService
//
//  Created by Rain on 1/31/16.
//  Copyright © 2016 Huawei. All rights reserved.
//


#import "SVDecode64.h"
#import "SVLog.h"
#import "SVRc4.h"
#import "SVYoukuSIDAndTokenAndEqGetter.h"
@implementation SVYoukuSIDAndTokenAndEqGetter


- (id)initWithEncrpytString:(NSString *)encryptString streamFileid:(NSString *)streamFileid
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    SVDebug (@"encryptString = %@,  streamFileid = %@ ", encryptString, streamFileid);
    // 计算 sid 和 token
    NSString *keyA = @"becaf9be";
    NSMutableArray *array = [SVDecode64 decode64:encryptString];
    NSString *temp = [SVRc4 Rc4:keyA byteArray:array isToBase64:false];
    NSArray *sidAndToken = [temp componentsSeparatedByString:@"_"];
    _sid = sidAndToken[0];
    _token = sidAndToken[1];

    // 计算 eq 的值
    NSString *keyB = @"bf7e5f01";
    NSString *whole = [NSString stringWithFormat:@"%@_%@_%@", _sid, streamFileid, _token];
    SVDebug (@"sid_vid_token = %@", whole);

    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    for (int j = 0; j < whole.length; j++)
    {
        NSNumber *myB0 = [NSNumber numberWithUnsignedChar:([whole characterAtIndex:j] & 0xff)];
        [array2 addObject:myB0];
    }
    NSString *eq = [SVRc4 Rc4:keyB byteArray:array2 isToBase64:true];
    _ep = (NSString *)CFBridgingRelease (
    CFURLCreateStringByAddingPercentEscapes (nil, (CFStringRef)eq, nil,
                                             (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    SVDebug (@"ep before:%@  convert to:%@", eq, _ep);
    return self;
}

- (NSString *)getSID
{
    return _sid;
}

- (NSString *)getToken
{
    return _token;
}

- (NSString *)getEq
{
    return _ep;
}

@end
