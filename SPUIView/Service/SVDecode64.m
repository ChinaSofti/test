//
//  TSDecode64.m
//  TaskService
//
//  Created by Rain on 1/30/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVDecode64.h"

@implementation SVDecode64

+ (NSMutableArray *)decode64:(NSString *)encrypt_string
{


    if (!encrypt_string)
    {
        return nil;
    }

    int f;
    NSUInteger g;
    NSMutableArray *l = [[NSMutableArray alloc] init];

    int i[] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60,
                61, -1, -1, -1, -1, -1, -1, -1, 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10,
                11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1,
                -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
                43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1 };

    for (g = encrypt_string.length, f = 0; g > f;)
    {
        int b;
        do
        {
            b = i[255 & [encrypt_string characterAtIndex:(f++)]];
        } while (g > f && -1 == b);

        if (-1 == b)
        {
            break;
        }

        int c;
        do
        {
            c = i[255 & [encrypt_string characterAtIndex:(f++)]];
        } while (g > f && -1 == c);

        if (-1 == c)
        {
            break;
        }

        Byte bytes0[] = { (Byte) (b << 2 | (48 & c) >> 4) };
        NSNumber *myB0 = [NSNumber numberWithUnsignedChar:bytes0[0]];
        [l addObject:myB0];

        int d;
        do
        {
            d = 255 & [encrypt_string characterAtIndex:(f++)];
            if (61 == d)
            {
                return l;
            }

            d = i[d];
        } while (g > f && -1 == d);

        if (-1 == d)
        {
            break;
        }

        Byte bytes1[] = { (Byte) ((15 & c) << 4 | (60 & d) >> 2) };
        NSNumber *myB1 = [NSNumber numberWithUnsignedChar:bytes1[0]];
        [l addObject:myB1];


        int e;
        do
        {
            e = 255 & [encrypt_string characterAtIndex:(f++)];
            if (61 == e)
            {
                return l;
            }
            e = i[e];
        } while (g > f && -1 == e);


        if (-1 == e)
        {
            break;
        }

        Byte bytes2[] = { (Byte) ((3 & d) << 6 | e) };
        NSNumber *myB2 = [NSNumber numberWithUnsignedChar:bytes2[0]];
        [l addObject:myB2];
    }


    return l;

    //    return nil;
}

@end
