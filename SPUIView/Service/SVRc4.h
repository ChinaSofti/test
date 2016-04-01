//
//  TSRc4.h
//  TaskService
//
//  Created by Rain on 1/30/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVRc4 : NSObject


+ (NSString *)Rc4:(NSString *)a byteArray:(NSMutableArray *)byteArray isToBase64:(BOOL)isToBase64;

@end
