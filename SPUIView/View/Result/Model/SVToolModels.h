//
//  SVToolModels.h
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVToolModels : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;


+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
