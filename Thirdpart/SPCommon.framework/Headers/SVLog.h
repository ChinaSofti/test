//
//  TSLog.h
//  Common
//
//  Created by Rain on 1/21/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#ifndef SVLog_h
#define SVLog_h


#define LOG_OBJC_MAYBE_ERROR(frmt, ...) \
    [SVLog warn:__PRETTY_FUNCTION__ line:__LINE__ format:(frmt), ##__VA_ARGS__]

#define LOG_OBJC_MAYBE_WARN(frmt, ...) \
    [SVLog warn:__PRETTY_FUNCTION__ line:__LINE__ format:(frmt), ##__VA_ARGS__]


#define LOG_OBJC_MAYBE_INFO(frmt, ...) \
    [SVLog info:__PRETTY_FUNCTION__ line:__LINE__ format:(frmt), ##__VA_ARGS__]


#define LOG_OBJC_MAYBE_DEBUG(frmt, ...) \
    [SVLog debug:__PRETTY_FUNCTION__ line:__LINE__ format:(frmt), ##__VA_ARGS__]


#define SVError(frmt, ...) LOG_OBJC_MAYBE_ERROR (frmt, ##__VA_ARGS__)
#define SVWarn(frmt, ...) LOG_OBJC_MAYBE_WARN (frmt, ##__VA_ARGS__)
#define SVInfo(frmt, ...) LOG_OBJC_MAYBE_INFO (frmt, ##__VA_ARGS__)
#define SVDebug(frmt, ...) LOG_OBJC_MAYBE_DEBUG (frmt, ##__VA_ARGS__)

#endif


#import <Foundation/Foundation.h>
/**
 *  日志记录器。
 *  支持ERROR，WARN，INFO，DEBUG四种级别日志
 */
@interface SVLog : NSObject


/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance;

/**
 *  覆写allocWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)allocWithZone:(struct _NSZone *)zone;

/**
 *  覆写copyWithZone方法
 *
 *  @param zone _NSZone
 *
 *  @return 单例对象
 */
+ (id)copyWithZone:(struct _NSZone *)zone;


/**
 *  ERROR级别日志记录
 *
 *  @param exception NSException|NSError 异常或错误对象
 *  @param format    消息
 */
+ (void)error:(const char *)function line:(unsigned int)line message:(NSString *)format, ...;

/**
 *  WARN级别日志记录
 *
 *  @param format 消息
 */
+ (void)warn:(const char *)function
        line:(unsigned int)line
      format:(NSString *)format, ... NS_FORMAT_FUNCTION (3, 4);

/**
 *  INFO级别日志记录
 *
 *  @param format 消息
 */
+ (void)info:(const char *)function
        line:(unsigned int)line
      format:(NSString *)format, ... NS_FORMAT_FUNCTION (3, 4);
/**
 *  DEBUG级别日志记录
 *
 *  @param format 消息
 */
+ (void)debug:(const char *)function
         line:(unsigned int)line
       format:(NSString *)format, ... NS_FORMAT_FUNCTION (3, 4);

/**
 *  日志记录，将日志打印到控制台或输出到文件中
 *
 *  @param functionName <#functionName description#>
 *  @param line         <#line description#>
 *  @param message      <#message description#>
 */
- (void)log:(int)level
functionName:(NSString *)functionName
        line:(unsigned int)line
     message:(NSString *)message;

/**
 *  获取日志文件路径
 *
 *  @return 日志文件路径
 */
- (NSString *)getLogFilePath;

/**
 *  压缩日志文件，并返回日志文件路径
 *
 *  @return 压缩后文件路径
 */
- (NSString *)compressLogFiles;

@end
