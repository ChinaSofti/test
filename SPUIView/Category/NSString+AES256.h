//
//  NSString+AES256.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/15.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>

#import "NSData+AES256.h"

@interface NSString (AES256)

- (NSString *)aes256_encrypt:(NSString *)key;
- (NSString *)aes256_decrypt:(NSString *)key;

@end