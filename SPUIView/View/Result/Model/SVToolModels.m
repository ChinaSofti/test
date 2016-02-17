//
//  SVTestingCtrl.m
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

        _title = dict[@"title"];
        _title2 = dict[@"title2"];
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end
