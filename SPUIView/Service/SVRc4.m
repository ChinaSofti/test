//
//  TSRc4.m
//  TaskService
//
//  Created by Rain on 1/30/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "GTMBase64.h"
#import "SVRc4.h"

@implementation SVRc4

+ (NSString *)Rc4:(NSString *)key byteArray:(NSMutableArray *)byteArray isToBase64:(BOOL)isToBase64
{
    // rc4加密算法
    int f = 0;
    int h = 0;
    int q = 0;
    int b[256];
    for (int i = 0; i < 256; i++)
    {
        b[i] = i;
    }
    while (h < 256)
    {

        f = (f + b[h] + [key characterAtIndex:(h % key.length)]) % 256;
        int temp = b[h];
        b[h] = b[f];
        b[f] = temp;
        h++;
    }

    f = 0;
    h = 0;
    q = 0;

    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    NSMutableArray *bytesR = [[NSMutableArray alloc] init];
    while (q < [byteArray count])
    {
        h = (h + 1) % 256;
        f = (f + b[h]) % 256;
        int temp = b[h];
        b[h] = b[f];
        b[f] = temp;


        NSNumber *objAtIndex = [byteArray objectAtIndex:q];
        Byte bytes0[] = { (Byte) (objAtIndex.unsignedCharValue ^ b[(b[h] + b[f]) % 256]) };
        int bytes0len = sizeof (bytes0) / sizeof (bytes0[0]);

        NSNumber *myB0 = [NSNumber numberWithUnsignedChar:bytes0[0]];
        [bytesR addObject:myB0];
        NSString *resul =
        [[NSString alloc] initWithBytes:bytes0 length:bytes0len encoding:NSASCIIStringEncoding];
        [result appendString:resul];
        q++;
    }

    if (isToBase64)
    {
        Byte bbb[bytesR.count];
        for (int j = 0; j < bytesR.count; j++)
        {
            NSNumber *num = [bytesR objectAtIndex:j];
            bbb[j] = num.unsignedCharValue;
        }

        int bbblen = (int)(sizeof (bbb) / sizeof (bbb[0]));
        NSData *ddd = [GTMBase64 encodeBytes:bbb length:bbblen];
        [result setString:[[NSString alloc] initWithData:ddd encoding:NSASCIIStringEncoding]];
    }

    return result;
}

@end
