//
//  SVToolModels.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVToolModels.h"

@implementation SVToolModels

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if ([super init])
    {

        _key = dict[@"key"];
        _value = dict[@"value"];
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end
