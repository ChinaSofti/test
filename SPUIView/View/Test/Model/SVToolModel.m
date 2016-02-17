//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVToolModel.h"

@implementation SVToolModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if ([super init])
    {
        _img_normal = dict[@"img_normal"];
        _img_selected = dict[@"img_selected"];
        _title = dict[@"title"];
        _rightImg_normal = dict[@"rightImg_normal"];
        _rightImg_selected = dict[@"rightImg_selected"];
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end
