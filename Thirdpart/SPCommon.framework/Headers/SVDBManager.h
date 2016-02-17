//
//  SVDBManager.h
//  SPUIView
//
//  Created by Rain on 2/12/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  数据库操作对象，支持执行更新和查询操作。
 */
@interface SVDBManager : NSObject

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance;

/**
 *  执行SQL语句进行更新操作
 *
 *  @param sql SQL语句 和 可变参数
 */
- (void)executeUpdate:(NSString *)sql, ...;

/**
 *  使用指定SQL进行查询，并将查询的每一条结果封装到clazz对象中。返回clazz对象数组
 *
 *  @param clazz 查询的每一条结果封装到clazz对象
 *  @param sql   SQL查询语句
 *
 *  @return clazz对象数组
 */
- (NSArray *)executeQuery:(Class)clazz SQL:(NSString *)sql, ...;

@end
