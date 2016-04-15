//
//  NSData+AES256.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/4/15.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>

@interface NSData (AES256)
- (NSData *)aes256_encrypt:(NSString *)key;
- (NSData *)aes256_decrypt:(NSString *)key;
@end
