//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVToolModels : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *title2;


+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
