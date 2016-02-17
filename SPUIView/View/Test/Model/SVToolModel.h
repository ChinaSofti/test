//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVToolModel : NSObject
@property (nonatomic, copy) NSString *img_normal;
@property (nonatomic, copy) NSString *img_selected;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *rightImg_normal;
@property (nonatomic, copy) NSString *rightImg_selected;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
