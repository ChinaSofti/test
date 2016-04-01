//
//  SVDBManager.m
//  SPUIView
//
//  Created by Rain on 2/12/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "FMDatabase.h"
#import "FMResultSet.h"
#import "SVDBManager.h"
#import "SVLog.h"

@implementation SVDBManager
{
    // fmdb 第三方数据库操作框架
    FMDatabase *_dataBase;
}

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVDBManager *dbManager;
    @synchronized (self)
    {
        if (dbManager == nil)
        {
            dbManager = [[super allocWithZone:NULL] init];
            [dbManager initDB];
        }
    }

    return dbManager;
}

- (void)initDB
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *documents = [paths objectAtIndex:0];
    NSString *dbPath = [documents stringByAppendingPathComponent:@"SpeedPro.db"];
    SVInfo (@"database path:%@", dbPath);

    // 2、在这个位置创建一个数据库
    if (_dataBase == nil)
    {
        _dataBase = [FMDatabase databaseWithPath:dbPath];
    }
}

/**
 *  覆写allocWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [SVDBManager sharedInstance];
}

/**
 *  覆写copyWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [SVDBManager sharedInstance];
}


/**
 *  执行SQL语句进行更新操作
 *
 *  @param sql SQL语句 和 可变参数
 */
- (void)executeUpdate:(NSString *)sql, ...
{
    va_list args;
    NSString *formatedSQL;
    if (sql)
    {
        va_start (args, sql);
        formatedSQL = [[NSString alloc] initWithFormat:sql arguments:args];
        SVInfo (@"sql:%@", formatedSQL);
        va_end (args);
    }

    @synchronized (self)
    {
        @try
        {
            if ([_dataBase open])
            {
                BOOL isSuccess = [_dataBase executeUpdate:formatedSQL];
                if (!isSuccess)
                {
                    SVError (@"sql execute fail.");
                }
            }
        }
        @catch (NSException *exception)
        {
            SVError (@"%@", exception);
        }
        @finally
        {
            [_dataBase close];
        }
    }
}

/**
 *  使用指定SQL进行查询，并将查询的每一条结果封装到clazz对象中。返回clazz对象数组
 *
 *  @param clazz 查询的每一条结果封装到clazz对象
 *  @param sql   SQL查询语句
 *
 *  @return clazz对象数组
 */
- (NSArray *)executeQuery:(Class)clazz SQL:(NSString *)sql, ...
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (!sql)
    {
        return array;
    }

    va_list args;
    va_start (args, sql);
    NSString *formatedSQL = [[NSString alloc] initWithFormat:sql arguments:args];
    va_end (args);
    SVInfo (@"sql:%@", formatedSQL);

    @synchronized (self)
    {
        // TODO liuchengyu 研究内省，支持非NSString 类型
        @try
        {
            if ([_dataBase open])
            {
                FMResultSet *set = [_dataBase executeQuery:formatedSQL];
                while ([set next])
                {
                    NSObject *obj = [[clazz alloc] init];
                    for (int i = 0; i < set.columnCount; i++)
                    {
                        @try
                        {
                            NSString *columnName = [set columnNameForIndex:i];
                            // NSLog (@"columnName:%@", columnName);
                            // [columnName capitalizedString] 字符串首字母大写
                            NSString *firstCharacter = [[columnName substringToIndex:1] uppercaseString];
                            NSString *lastCharacter = [columnName substringFromIndex:1];
                            SEL sel = NSSelectorFromString (
                            [NSString stringWithFormat:@"set%@%@:", firstCharacter, lastCharacter]);
                            NSString *value = [set stringForColumn:columnName];
                            [obj performSelector:sel withObject:value];
                        }
                        @catch (NSException *exception)
                        {
                            SVError (@"%@", exception);
                        }
                    }

                    [array addObject:obj];
                }
            }
        }
        @catch (NSException *exception)
        {
            SVError (@"%@", exception);
        }
        @finally
        {
            [_dataBase close];
        }
    }

    return array;
}

@end
