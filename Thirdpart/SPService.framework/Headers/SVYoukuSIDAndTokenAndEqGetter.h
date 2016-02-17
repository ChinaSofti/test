//
//  TSYoukuSIDAndTokenAndEqGetter.h
//  TaskService
//
//  Created by Rain on 1/31/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVYoukuSIDAndTokenAndEqGetter : NSObject
{
    NSString *_sid;
    NSString *_token;
    NSString *_ep;
}


- (id)initWithEncrpytString:(NSString *)encryptString streamFileid:(NSString *)streamFileid;

- (NSString *)getSID;

- (NSString *)getToken;

- (NSString *)getEq;

@end
