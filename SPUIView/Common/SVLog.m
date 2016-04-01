//
//  CTLog.m
//  Common
//
//  Created by Rain on 1/21/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "CocoaLumberjack.h"
#import "SVLog.h"
#import "SVTimeUtil.h"
#import "ZipArchive.h"

@implementation SVLog

static const NSUInteger ddLogLevel = DDLogLevelAll;

static NSString *logFilePath;

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVLog *log;
    @synchronized (self)
    {
        if (log == nil)
        {
            log = [[super allocWithZone:NULL] init];
            // 初始化DDLog日志输出，在这里，我们仅仅希望在xCode控制台输出
            [DDLog addLogger:[DDTTYLogger sharedInstance]];

            DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] init];
            [logFileManager setMaximumNumberOfLogFiles:6];
            DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
            fileLogger.maximumFileSize = 5 * 1024 * 1024; // 5 MB
            [DDLog addLogger:fileLogger];
            logFilePath = fileLogger.logFileManager.logsDirectory;
            // 2.2打印日志文件目录
            NSLog (@"dir of log file:%@", logFilePath);
        }
    }

    return log;
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
    return [SVLog sharedInstance];
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
    return [SVLog sharedInstance];
}


/**
 *  ERROR级别日志记录
 *
 *  @param exception NSException|NSError 异常或错误对象
 *  @param format    消息
 */
+ (void)error:(const char *)function line:(unsigned int)line message:(NSString *)format, ...
{
    va_list args;

    if (format)
    {
        va_start (args, format);

        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *functionName =
        [[NSString alloc] initWithCString:function encoding:NSUTF8StringEncoding];
        SVLog *log = [SVLog sharedInstance];
        [log log:3 functionName:functionName line:line message:message];
        va_end (args);
    }
}

/**
 *  WARN级别日志记录
 *
 *  @param format 消息
 */
+ (void)warn:(const char *)function line:(unsigned int)line format:(NSString *)format, ...
{
    va_list args;

    if (format)
    {
        va_start (args, format);

        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *functionName =
        [[NSString alloc] initWithCString:function encoding:NSUTF8StringEncoding];
        //        [SVLog _log:functionName line:line message:message];
        SVLog *log = [SVLog sharedInstance];
        [log log:2 functionName:functionName line:line message:message];
        va_end (args);
    }
}

/**
 *  INFO级别日志记录
 *
 *  @param format 消息
 */
+ (void)info:(const char *)function line:(unsigned int)line format:(NSString *)format, ...
{

    va_list args;

    if (format)
    {
        va_start (args, format);

        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *functionName =
        [[NSString alloc] initWithCString:function encoding:NSUTF8StringEncoding];
        SVLog *log = [SVLog sharedInstance];
        [log log:1 functionName:functionName line:line message:message];
        va_end (args);
    }
}
/**
 *  DEBUG级别日志记录
 *
 *  @param format 消息
 */
+ (void)debug:(const char *)function line:(unsigned int)line format:(NSString *)format, ...
{
    va_list args;

    if (format)
    {
        va_start (args, format);

        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *functionName =
        [[NSString alloc] initWithCString:function encoding:NSUTF8StringEncoding];
        SVLog *log = [SVLog sharedInstance];
        [log log:0 functionName:functionName line:line message:message];
        va_end (args);
    }
}


/**
 *  日志记录，将日志打印到控制台或输出到文件中
 *
 *  @param level 日志级别
 *  @param functionName 函数名
 *  @param line         行号
 *  @param message      消息
 */
- (void)log:(int)level
functionName:(NSString *)functionName
        line:(unsigned int)line
     message:(NSString *)message
{
    switch (level)
    {
    case 0:
        DDLogVerbose (@"DEBUG %d %@ %@", line, functionName, message);
        break;
    case 1:
        DDLogInfo (@"INFO %d %@ %@", line, functionName, message);
        break;
    case 2:
        DDLogWarn (@"WARN %d %@ %@", line, functionName, message);
        break;
    case 3:
        DDLogError (@"ERROR %d %@ %@", line, functionName, message);
        break;
    default:
        DDLogInfo (@"INFO %d %@ %@", line, functionName, message);
        break;
    }
}


/**
 *  获取日志文件路径
 *
 *  @return 日志文件路径
 */
- (NSString *)getLogFilePath
{
    return logFilePath;
}

/**
 *  压缩日志文件，并返回日志文件路径
 *
 *  @return 压缩后文件路径
 */
- (NSString *)compressLogFiles
{
    NSString *compressedFileName = [self getCompressLogFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fileManager subpathsAtPath:logFilePath];
    ZipArchive *archive = [[ZipArchive alloc] init];
    NSString *compressedLogFile = [logFilePath stringByAppendingPathComponent:compressedFileName];
    BOOL isOK = [archive CreateZipFile2:compressedLogFile];
    if (!isOK)
    {
        SVError (@"create log zip file fail.");
        return nil;
    }

    for (NSString *fileName in files)
    {
        if (![fileName containsString:@"com.huawei.speedpro"])
        {
            continue;
        }

        //        NSLog (@"fileName:%@", fileName);
        isOK = [archive addFileToZip:[logFilePath stringByAppendingPathComponent:fileName]
                             newname:fileName];
        if (!isOK)
        {
            SVError (@"add log file[file name:%@] to zip fail.", fileName);
            continue;
        }
    }
    isOK = [archive CloseZipFile2];
    if (!isOK)
    {
        SVError (@"close log zip file fail.");
        return nil;
    }

    return compressedLogFile;
}

- (NSString *)getCompressLogFileName
{

    NSString *compressedLogFileName = [NSString
    stringWithFormat:@"%@_%@_%@.zip", @"ios_speedpro", @"1.1.1.1", [SVTimeUtil currentTimeStamp]];
    return compressedLogFileName;
}

/**
 *  清除所有日志
 */
+ (void)clearAllLog
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fileManager subpathsAtPath:logFilePath];
    for (NSString *fileName in files)
    {
        NSString *filePath = [logFilePath stringByAppendingPathComponent:fileName];
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if (error)
        {
            SVError (@"delete log file fail. file path:%@,  error:%@", filePath, error);
        }
        else
        {
            SVInfo (@"delete log file success. file path:%@", filePath);
        }
    }

    SVInfo (@"finish to clear log file.");
}


@end
