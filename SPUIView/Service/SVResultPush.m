//
//  SVResultPush.m
//  SpeedPro
//
//  Created by 李灏 on 16/3/13.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVAppVersionChecker.h"
#import "SVCurrentDevice.h"
#import "SVDBManager.h"
#import "SVDetailResultModel.h"
#import "SVHttpsTools.h"
#import "SVIPAndISPGetter.h"
#import "SVProbeInfo.h"
#import "SVResultPush.h"
#import "SVUploadFile.h"
#import "SVUrlTools.h"
#import "SVUvMOSCalculator.h"

@interface SVResultPush ()

@property (strong) SVResultPush *currPush;

@end

@implementation SVResultPush
{
    SVCurrentResultModel *_resultModel;

    NSMutableData *_allData;


    NSString *_mobileidStr;

    BOOL finished;

    long long _svTestId;
    long long *_svTestTime;

    SVDBManager *_db;
    NSArray *_videoResultArray;
    NSArray *_webResultArray;
    NSArray *_speedResultArray;

    NSArray *_emptyArr;

    // 上传结果失败后尝试次数。上传结果连续3次都上传失败，则取消结果上传
    int _failCount;

    // 上报结果后，服务器响应的数据
    NSData *_responseData;

    // 是否需要上传日志
    BOOL needUploadLogFile;
}

- (id)initWithTestId:(long long)testId
{
    self = [super init];
    if (self)
    {
        _svTestId = testId;
        _db = [SVDBManager sharedInstance];
        _emptyArr = [[NSArray alloc] init];
    }

    return self;
}

- (void)sendResult:(CompletionHandler)handler
{
    _handler = handler;
    [self queryResult];

    // 3.设置请求体
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];


    NSMutableDictionary *collectorResultsDic;
    NSMutableDictionary *speedTestResultsDic;
    NSMutableDictionary *videoTestResultsDic;
    NSMutableDictionary *webTestResultsDic;

    @try
    {
        collectorResultsDic = [self genCollectorResultsDic];
    }
    @catch (NSException *e)
    {
        SVError (@"genCollectorResultsDic error! %@", e);
    }

    @try
    {
        speedTestResultsDic = [self genSpeedTestResultsDic];
    }
    @catch (NSException *e)
    {
        SVError (@"genSpeedTestResultsDic error! %@", e);
    }

    @try
    {
        videoTestResultsDic = [self genVideoTestResultsDic];
    }
    @catch (NSException *e)
    {
        SVError (@"genVideoTestResultsDic error! %@", e);
    }

    @try
    {
        webTestResultsDic = [self genWebTestResultsDic];
    }
    @catch (NSException *e)
    {
        SVError (@"genWebTestResultsDic error! %@", e);
    }

    if (collectorResultsDic)
    {
        [dic setObject:collectorResultsDic forKey:@"collectorResults"];

        if (speedTestResultsDic)
        {
            [dic setObject:speedTestResultsDic forKey:@"speedTestResults"];
        }

        if (videoTestResultsDic)
        {
            [dic setObject:videoTestResultsDic forKey:@"videoTestResults"];
        }

        if (webTestResultsDic)
        {
            [dic setObject:webTestResultsDic forKey:@"webTestResults"];
        }
    }

    NSString *resultJson = [self dictionaryToJsonString:dic];
    SVInfo (@"json = %@", resultJson);
    [self sendResultToServer:resultJson];
}

- (void)sendResultToServer:(NSString *)resultJson
{
    NSURL *url = [[NSURL alloc] initWithString:[SVUrlTools getResultUploadUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setHTTPBody:[resultJson dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:10];
    [request setHTTPMethod:@"POST"];

    // 设置Content-Type
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];


    // 连接服务器发送结果
    SVHttpsTools *httpsTools = [[SVHttpsTools alloc] init];
    [httpsTools sendRequest:request
          completionHandler:^(NSData *responseData, NSError *error) {
            // 上报结果失败
            if (error)
            {
                _failCount++;
                if (_failCount < 3)
                {
                    SVError (@"retry send result to server. result push error:%@ ", error);
                    [self sendResultToServer:resultJson];
                    return;
                }

                _handler (nil, error);
                return;
            }

            _responseData = responseData;
            NSString *mesg =
            [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            SVInfo (@"send result success. response data:%@", mesg);

            if (_handler)
            {
                _handler (responseData, nil);
            }

            if (needUploadLogFile)
            {
                // 测试失败时，上报日志文件
                [self sendLogFileToServerWhenTestFail];
            }
          }];
}

/**
 *  测试失败时，上报日志文件
 */
- (void)sendLogFileToServerWhenTestFail
{
    SVLog *log = [SVLog sharedInstance];
    NSString *filePath = [log compressLogFiles];
    SVInfo (@"upload log file:%@", filePath);

    SVUploadFile *upload = [[SVUploadFile alloc] init];
    // 设置上报日志过程显示Toast提示用户上报进度
    [upload setShowToast:FALSE];
    [upload uploadFile:filePath];
}

- (void)queryResult
{
    //    sleep (2);

    // 拼写sql // 测试类型：0=video,1=web,2=speed
    NSMutableString *vsql = [NSMutableString
    stringWithFormat:@"select * from SVDetailResultModel where testId=%lld and testType=0", _svTestId];

    NSMutableString *wsql = [NSMutableString
    stringWithFormat:@"select * from SVDetailResultModel where testId=%lld and testType=1", _svTestId];

    NSMutableString *ssql = [NSMutableString
    stringWithFormat:@"select * from SVDetailResultModel where testId=%lld and testType=2", _svTestId];

    // 查询结果，如果结果为空则返回
    _videoResultArray = [_db executeQuery:[SVDetailResultModel class] SQL:vsql];
    _webResultArray = [_db executeQuery:[SVDetailResultModel class] SQL:wsql];
    _speedResultArray = [_db executeQuery:[SVDetailResultModel class] SQL:ssql];
}


//输出浮点型的数值,保留2位小数+单位
- (NSString *)formatFloatValue:(NSString *)value unit:(NSString *)unit
{
    return [NSString stringWithFormat:@"%.2f%@ ", [value floatValue], unit];
}


- (NSString *)ispFilter:(SVIPAndISP *)isp str:(NSString *)str
{
    if (!isp || !str)
    {
        return @"";
    }

    return str;
}

- (NSMutableDictionary *)genCollectorResultsDic
{
    // 1. collectorResults
    // 1.1 location

    SVIPAndISP *isp = [[SVIPAndISPGetter sharedInstance] getIPAndISP];
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];

    NSMutableDictionary *locationDic = [[NSMutableDictionary alloc] init];
    [locationDic setObject:[self ispFilter:isp str:isp.as] forKey:@"as"];
    [locationDic setObject:[self ispFilter:isp str:isp.carrier] forKey:@"carrier"];
    [locationDic setObject:[self ispFilter:isp str:isp.city] forKey:@"city"];
    [locationDic setObject:[self ispFilter:isp str:isp.country] forKey:@"country"];
    [locationDic setObject:[self ispFilter:isp str:isp.countryCode] forKey:@"countryCode"];
    [locationDic setObject:@"" forKey:@"district"];
    [locationDic setObject:[self hideIp:[self ispFilter:isp str:isp.query]] forKey:@"ip"];
    [locationDic setObject:[self ispFilter:isp str:isp.isp] forKey:@"isp"];

    // 获取经纬度
    NSString *latStr = [probeInfo getLatitude];
    if (!latStr || latStr.length == 0)
    {
        latStr = [self ispFilter:isp str:isp.lat];
    }
    NSString *lonStr = [probeInfo getLongitude];
    if (!lonStr || lonStr.length == 0)
    {
        lonStr = [self ispFilter:isp str:isp.lon];
    }
    [locationDic setObject:latStr forKey:@"lat"];
    [locationDic setObject:lonStr forKey:@"lon"];

    [locationDic setObject:@"" forKey:@"message"];
    [locationDic setObject:[self ispFilter:isp str:isp.org] forKey:@"org"];
    [locationDic setObject:@"" forKey:@"province"];
    [locationDic setObject:[self hideIp:[self ispFilter:isp str:isp.query]] forKey:@"query"];
    [locationDic setObject:[self ispFilter:isp str:isp.region] forKey:@"region"];
    [locationDic setObject:[self ispFilter:isp str:isp.regionName] forKey:@"regionName"];
    [locationDic setObject:@"success" forKey:@"status"];
    [locationDic setObject:[self ispFilter:isp str:isp.timezone] forKey:@"timezone"];
    [locationDic setObject:[self ispFilter:isp str:isp.zip] forKey:@"zip"];

    // 1.2 param
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];

    // 手机别名: iPhone Simulator
    //    NSString *userPhoneName = [[UIDevice currentDevice] name];

    // 设备名称: iPhone OS
    NSString *deviceName = [[UIDevice currentDevice] systemName];

    // 手机系统版本: 9.2
    //    NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];

    // 手机型号: iPhone
    //    NSString *phoneModel = [[UIDevice currentDevice] model];

    NSString *localIP = [SVCurrentDevice getIPAddress];

    // UUID
    NSString *uuid = [probeInfo getUUID];

    //    NSString *mobilename = [NSString stringWithFormat:@"%@ %@ %@", userPhoneName, deviceName,
    //    phoneVersion];

    [paramDic setObject:@0 forKey:@"cellid"];
    [paramDic setObject:!uuid ? @"" : uuid forKey:@"mobileid"];
    _mobileidStr = !uuid ? @"" : uuid;
    [paramDic setObject:!localIP ? @"" : [self hideIp:localIP] forKey:@"mobileip"];
    [paramDic setObject:deviceName forKey:@"mobilename"];
    //    [paramDic setObject:mobilename forKey:@"mobilename"];
    [paramDic setObject:[self ispFilter:isp str:isp.isp] forKey:@"operatorname"];
    [paramDic setObject:@"" forKey:@"operatornw"];
    NSMutableDictionary *collectorResultsDic = [[NSMutableDictionary alloc] init];
    NSString *bw = [probeInfo getBandwidth];
    NSNumber *bwNumber = [NSNumber numberWithInt:[bw intValue]];
    [collectorResultsDic setObject:!bw ? @0 : bwNumber forKey:@"bandwidth"];
    NSString *bandwidthType = [probeInfo getBandwidthType];
    NSNumber *bandwidthTypeNumber = [NSNumber numberWithInt:[bandwidthType intValue]];
    [collectorResultsDic setObject:bandwidthTypeNumber forKey:@"bandwidthType"];
    [collectorResultsDic setObject:@"SUCCESS" forKey:@"completions"];
    [collectorResultsDic setObject:@0 forKey:@"id"];
    [collectorResultsDic setObject:locationDic forKey:@"location"];

    int networkType = !probeInfo.networkType ? 1 : probeInfo.networkType;
    [collectorResultsDic setObject:[[NSNumber alloc] initWithInt:networkType]
                            forKey:@"networktype"];
    [collectorResultsDic setObject:paramDic forKey:@"param"];
    [collectorResultsDic setObject:@0 forKey:@"sampleTime"];
    [collectorResultsDic setObject:@0 forKey:@"signalStrength"];
    [collectorResultsDic setObject:@0 forKey:@"SNR"];
    [collectorResultsDic setObject:@0 forKey:@"testId"];
    [collectorResultsDic setObject:[SVAppVersionChecker currentVersion] forKey:@"softwareVersion"];
    [collectorResultsDic setObject:[SVUvMOSCalculator getSDKCurVersion] forKey:@"uvmosVersion"];
    [collectorResultsDic setObject:[NSNumber numberWithLongLong:_svTestId] forKey:@"testTime"];

    return collectorResultsDic;
}

- (NSString *)hideIp:(NSString *)ip
{
    NSString *mobileIp = ip;
    if ([mobileIp containsString:@"."])
    {
        NSArray *array = [mobileIp componentsSeparatedByString:@"."];
        mobileIp = [NSString stringWithFormat:@"%@.%@.%@.***", array[0], array[1], array[2]];
    }
    return mobileIp;
}

- (NSMutableDictionary *)genSpeedTestResultsDic
{
    // 2. speedTestResults
    // 2.1 location
    //[testResultJson valueForKey:@"downloadSpeed"];
    if (_speedResultArray.count == 0)
    {
        needUploadLogFile = TRUE;
        return nil;
    }

    SVDetailResultModel *model = [_speedResultArray objectAtIndex:0];
    NSString *testResult = model.testResult;
    NSError *error;
    id speedTestResultJson =
    [NSJSONSerialization JSONObjectWithData:[testResult dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0
                                      error:&error];

    NSMutableDictionary *locationDic = [[NSMutableDictionary alloc] init];
    if (error)
    {
        return locationDic;
    }


    [locationDic setObject:@"" forKey:@"as"];
    [locationDic setObject:@"" forKey:@"carrier"];
    [locationDic setObject:[speedTestResultJson valueForKey:@"location"] forKey:@"city"];
    [locationDic setObject:@"" forKey:@"country"];
    [locationDic setObject:@"" forKey:@"countryCode"];
    [locationDic setObject:@"" forKey:@"district"];
    [locationDic setObject:@"" forKey:@"ip"];
    [locationDic setObject:[speedTestResultJson valueForKey:@"isp"] forKey:@"isp"];
    [locationDic setObject:@"" forKey:@"lat"];
    [locationDic setObject:@"" forKey:@"lon"];
    [locationDic setObject:@"" forKey:@"message"];
    [locationDic setObject:@"" forKey:@"org"];
    [locationDic setObject:@"" forKey:@"province"];
    [locationDic setObject:@"" forKey:@"query"];
    [locationDic setObject:@"" forKey:@"region"];
    [locationDic setObject:@"" forKey:@"regionName"];
    [locationDic setObject:@"success" forKey:@"status"];
    [locationDic setObject:@"" forKey:@"timezone"];
    [locationDic setObject:@"" forKey:@"zip"];
    //}


    // 2.2 upAverage
    NSMutableDictionary *upAverageDic = [[NSMutableDictionary alloc] init];
    [upAverageDic setObject:@"SUCCESS" forKey:@"completions"];
    [upAverageDic setObject:@0 forKey:@"id"];
    [upAverageDic setObject:@1 forKey:@"isAverage"];
    [upAverageDic setObject:@0 forKey:@"isUpload"];
    [upAverageDic setObject:@1457841583057 forKey:@"sampleTime"];
    NSNumber *upSpeed =
    [[NSNumber alloc] initWithFloat:[[speedTestResultJson valueForKey:@"uploadSpeed"] floatValue]];
    if (upSpeed.floatValue < 0)
    {
        needUploadLogFile = TRUE;
    }

    [upAverageDic setObject:upSpeed forKey:@"speed"];
    [upAverageDic setObject:@"0" forKey:@"testId"];

    // 2.3 downAverage
    NSMutableDictionary *downAverageDic = [[NSMutableDictionary alloc] init];
    [downAverageDic setObject:@"SUCCESS" forKey:@"completions"];
    [downAverageDic setObject:@0 forKey:@"id"];
    [downAverageDic setObject:@1 forKey:@"isAverage"];
    [downAverageDic setObject:@1 forKey:@"isUpload"];
    [downAverageDic setObject:@1457841583057 forKey:@"sampleTime"];
    NSNumber *downSpeed =
    [[NSNumber alloc] initWithFloat:[[speedTestResultJson valueForKey:@"downloadSpeed"] floatValue]];

    if (downSpeed.floatValue < 0)
    {
        needUploadLogFile = TRUE;
    }

    [downAverageDic setObject:downSpeed forKey:@"speed"];
    [downAverageDic setObject:@"0" forKey:@"testId"];

    NSMutableDictionary *speedTestResultsDic = [[NSMutableDictionary alloc] init];
    [speedTestResultsDic setObject:@"SUCCESS" forKey:@"completions"];
    NSNumber *delay = [[NSNumber alloc] initWithLong:[[speedTestResultJson valueForKey:@"delay"] longValue]];
    [speedTestResultsDic setObject:delay forKey:@"delay"];
    [speedTestResultsDic setObject:downAverageDic forKey:@"downAverage"]; // TODO yzy
    [speedTestResultsDic setObject:@"SUCCESS" forKey:@"downCompletions"];
    [speedTestResultsDic setObject:_emptyArr forKey:@"downSample"];
    [speedTestResultsDic setObject:@0 forKey:@"id"];
    [speedTestResultsDic setObject:locationDic forKey:@"location"];
    [speedTestResultsDic setObject:@0.0 forKey:@"maxDownloadSpeed"];
    [speedTestResultsDic setObject:@0.0 forKey:@"maxUploadSpeed"];
    [speedTestResultsDic setObject:@0.0 forKey:@"minDownloadSpeed"];
    [speedTestResultsDic setObject:@0.0 forKey:@"minUploadSpeed"];
    [speedTestResultsDic setObject:@0 forKey:@"sampleTime"];
    [speedTestResultsDic setObject:@0 forKey:@"testId"];
    [speedTestResultsDic setObject:upAverageDic forKey:@"upAverage"];
    [speedTestResultsDic setObject:@"SUCCESS" forKey:@"upCompletions"];
    [speedTestResultsDic setObject:_emptyArr forKey:@"upSample"];

    return speedTestResultsDic;
}

- (NSMutableDictionary *)genVideoTestResultsDic
{
    // 3. videoTestResults
    // 3.1 location
    if (_videoResultArray.count == 0)
    {
        needUploadLogFile = TRUE;
        return nil;
    }

    NSError *error;
    SVDetailResultModel *model = [_videoResultArray objectAtIndex:0];
    NSString *testResultString = model.testResult;
    id videoTestResultJson =
    [NSJSONSerialization JSONObjectWithData:[testResultString dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0
                                      error:&error];


    NSString *testContextString = model.testContext;
    id videoTestContextJson =
    [NSJSONSerialization JSONObjectWithData:[testContextString dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0
                                      error:&error];

    // CDN信息
    NSMutableArray *cdnInfoArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *locationDic;
    NSString *ipAddress;
    int index = 0;
    for (NSString *key in [videoTestContextJson allKeys])
    {
        if ([key isEqualToString:@"videoPlayDuration"] || [key isEqualToString:@"videoURL"])
        {
            continue;
        }

        // 将json字符串转换成字典
        NSData *segementData = [[videoTestContextJson objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding];
        id segementJson =
        [NSJSONSerialization JSONObjectWithData:segementData options:0 error:&error];
        if (error)
        {
            SVError (@"%@", error);
            continue;
        }

        // 单个分片信息
        NSMutableDictionary *cdnInfo = [[NSMutableDictionary alloc] init];
        ipAddress = [segementJson valueForKey:@"videoSegementIP"];
        [cdnInfo setObject:key forKey:@"videoUrl"];
        [cdnInfo setObject:ipAddress forKey:@"ipAddress"];

        // 地址信息
        locationDic = [[NSMutableDictionary alloc] init];
        SVIPAndISP *isp = [[SVIPAndISPGetter sharedInstance] queryIPDetail:ipAddress];
        if (isp)
        {
            [locationDic setObject:[self ispFilter:isp str:isp.as] forKey:@"as"];
            [locationDic setObject:[self ispFilter:isp str:isp.carrier] forKey:@"carrier"];
            [locationDic setObject:[self ispFilter:isp str:isp.city] forKey:@"city"];
            [locationDic setObject:[self ispFilter:isp str:isp.country] forKey:@"country"];
            [locationDic setObject:[self ispFilter:isp str:isp.countryCode] forKey:@"countryCode"];
            [locationDic setObject:@"" forKey:@"district"];
            [locationDic setObject:[self ispFilter:isp str:isp.query] forKey:@"ip"];
            [locationDic setObject:[self ispFilter:isp str:isp.isp] forKey:@"isp"];
            [locationDic setObject:[self ispFilter:isp str:isp.lat] forKey:@"lat"];
            [locationDic setObject:[self ispFilter:isp str:isp.lon] forKey:@"lon"];
            [locationDic setObject:@"" forKey:@"message"];
            [locationDic setObject:[self ispFilter:isp str:isp.org] forKey:@"org"];
            [locationDic setObject:@"" forKey:@"province"];
            [locationDic setObject:[self ispFilter:isp str:isp.query] forKey:@"query"];
            [locationDic setObject:[self ispFilter:isp str:isp.region] forKey:@"region"];
            [locationDic setObject:[self ispFilter:isp str:isp.regionName] forKey:@"regionName"];
            [locationDic setObject:@"success" forKey:@"status"];
            [locationDic setObject:[self ispFilter:isp str:isp.timezone] forKey:@"timezone"];
            [locationDic setObject:[self ispFilter:isp str:isp.zip] forKey:@"zip"];
        }
        else
        {
            [locationDic setObject:@"" forKey:@"as"];
            [locationDic setObject:@"" forKey:@"carrier"];
            [locationDic setObject:@"" forKey:@"city"];
            [locationDic setObject:@"" forKey:@"country"];
            [locationDic setObject:@"" forKey:@"countryCode"];
            [locationDic setObject:@"" forKey:@"district"];
            [locationDic setObject:@"" forKey:@"ip"];
            [locationDic setObject:@"" forKey:@"isp"];
            [locationDic setObject:@"" forKey:@"lat"];
            [locationDic setObject:@"" forKey:@"lon"];
            [locationDic setObject:@"" forKey:@"message"];
            [locationDic setObject:@"" forKey:@"org"];
            [locationDic setObject:@"" forKey:@"province"];
            [locationDic setObject:@"" forKey:@"query"];
            [locationDic setObject:@"" forKey:@"region"];
            [locationDic setObject:@"" forKey:@"regionName"];
            [locationDic setObject:@"success" forKey:@"status"];
            [locationDic setObject:@"" forKey:@"timezone"];
            [locationDic setObject:@"" forKey:@"zip"];
        }

        [cdnInfo setObject:locationDic forKey:@"location"];
        [cdnInfo setObject:[[NSNumber alloc] initWithInt:index] forKey:@"cdnId"];
        [cdnInfo setObject:[self string2num:[segementJson valueForKey:@"videoSegementSize"]]
                    forKey:@"videoSize"];
        [cdnInfo setObject:[self string2num:[segementJson valueForKey:@"videoSegementDuration"]]
                    forKey:@"playTotalDuration"];

        [cdnInfoArray addObject:cdnInfo];
        index++;
    }

    // 3.2 mediaInput
    NSMutableDictionary *mediaInputDic = [[NSMutableDictionary alloc] init];
    [mediaInputDic setObject:[self string2num:[videoTestResultJson valueForKey:@"bitrate"]]
                      forKey:@"mediaAvgVideoBitrate"];
    [mediaInputDic setObject:@0.0 forKey:@"mediaCodecType"];
    [mediaInputDic setObject:@4 forKey:@"mediaContentProvider"];
    [mediaInputDic setObject:[self string2num:[videoTestResultJson valueForKey:@"frameRate"]]
                      forKey:@"mediaFrameRate"];
    [mediaInputDic setObject:[videoTestResultJson valueForKey:@"videoHeight"]
                      forKey:@"mediaHeightResolution"];
    [mediaInputDic setObject:[videoTestResultJson valueForKey:@"videoWidth"]
                      forKey:@"mediaWidthResolution"];
    [mediaInputDic setObject:@0 forKey:@"periodAvgKeyFrameSize"];
    [mediaInputDic setObject:[self string2num:[videoTestResultJson valueForKey:@"bitrate"]]
                      forKey:@"periodAvgVideoBitrate"];
    [mediaInputDic setObject:[self string2num:[videoTestResultJson valueForKey:@"playDuration"]]
                      forKey:@"playTotalTime"];
    [mediaInputDic setObject:@0 forKey:@"screenHeightResolution"];
    [mediaInputDic setObject:@42 forKey:@"screenSize"];
    [mediaInputDic setObject:@0 forKey:@"screenWidthResolution"];
    [mediaInputDic setObject:[self string2num:[videoTestResultJson valueForKey:@"firstBufferTime"]]
                      forKey:@"sloadingInitBufferLatency"];
    [mediaInputDic
    setObject:[self string2num:[videoTestResultJson valueForKey:@"videoCuttonTotalTime"]]
       forKey:@"stallingRebufferingDuration"];
    [mediaInputDic setObject:@0.0 forKey:@"stallingRebufferingFrequency"];
    [mediaInputDic setObject:@0.0 forKey:@"stallingRebufferingInterval"];

    // 3.3 ottTestParams
    NSMutableDictionary *ottTestParamsDic = [[NSMutableDictionary alloc] init];
    [ottTestParamsDic setObject:@"" forKey:@"osType"];
    [ottTestParamsDic setObject:@"" forKey:@"passWord"];
    [ottTestParamsDic setObject:@NO forKey:@"proxyEnable"];
    [ottTestParamsDic setObject:@"" forKey:@"proxyIp"];
    [ottTestParamsDic setObject:@0 forKey:@"proxyPort"];
    // videoPlayDuration
    [ottTestParamsDic setObject:[videoTestContextJson valueForKey:@"videoPlayDuration"]
                         forKey:@"testDuration"];
    [ottTestParamsDic setObject:[videoTestContextJson valueForKey:@"videoURL"] forKey:@"testUrl"];
    [ottTestParamsDic setObject:@"" forKey:@"userName"];
    [ottTestParamsDic setObject:!ipAddress ? @"" : ipAddress forKey:@"videoServerIp"];
    [ottTestParamsDic setObject:@80 forKey:@"videoServerPort"];
    [ottTestParamsDic setObject:@0 forKey:@"videoSize"];
    [ottTestParamsDic setObject:@"MP4" forKey:@"videoType"];
    [ottTestParamsDic setObject:@"" forKey:@"videoUrl"];

    // 3.4 uvMOSScore
    NSMutableDictionary *uvMOSScoreDic = [[NSMutableDictionary alloc] init];
    [uvMOSScoreDic setObject:@0.0 forKey:@"satCurUvmos"];
    NSNumber *sQualitySession =
    [self string2num:[videoTestResultJson valueForKey:@"sQualitySession"]];
    if (sQualitySession.floatValue < 0)
    {
        needUploadLogFile = TRUE;
    }

    [uvMOSScoreDic setObject:sQualitySession forKey:@"satSequenceSquality"];
    [uvMOSScoreDic setObject:[self string2num:[videoTestResultJson valueForKey:@"sViewSession"]]
                      forKey:@"satSequenceSview"];
    [uvMOSScoreDic setObject:[self string2num:[videoTestResultJson valueForKey:@"UvMOSSession"]]
                      forKey:@"satSequenceUvmos"];
    [uvMOSScoreDic
    setObject:[self string2num:[videoTestResultJson valueForKey:@"sInteractionSession"]]
       forKey:@"satSinteractionMos"];
    [uvMOSScoreDic setObject:@0.0 forKey:@"satSqualityMos"];
    [uvMOSScoreDic setObject:@0.0 forKey:@"satStallingMos"];
    [uvMOSScoreDic setObject:@0.0 forKey:@"satSviewMos"];

    NSMutableDictionary *videoTestResultsDic = [[NSMutableDictionary alloc] init];
    [videoTestResultsDic setObject:[self string2num:[videoTestResultJson valueForKey:@"bitrate"]]
                            forKey:@"aveBitRate"];
    [videoTestResultsDic setObject:[self string2int:[videoTestResultJson valueForKey:@"errorCode"]]
                            forKey:@"errorCode"];

    [videoTestResultsDic
    setObject:[self string2num:[videoTestResultJson valueForKey:@"videoCuttonTotalTime"]]
       forKey:@"bufferTime"];
    [videoTestResultsDic
    setObject:[self string2num:[videoTestResultJson valueForKey:@"videoCuttonTimes"]]
       forKey:@"bufferTimes"];
    [videoTestResultsDic setObject:@"SUCCESS" forKey:@"completions"];
    [videoTestResultsDic
    setObject:[self string2num:[videoTestResultJson valueForKey:@"downloadSpeed"]]
       forKey:@"downloadSpeedAvg"];
    [videoTestResultsDic setObject:@0.0 forKey:@"downloadSpeedMax"];
    [videoTestResultsDic setObject:@0 forKey:@"id"];
    [videoTestResultsDic
    setObject:[self string2num:[videoTestResultJson valueForKey:@"firstBufferTime"]]
       forKey:@"initialBufferTime"];
    [videoTestResultsDic setObject:locationDic forKey:@"location"];
    [videoTestResultsDic setObject:mediaInputDic forKey:@"mediaInput"];
    [videoTestResultsDic setObject:ottTestParamsDic forKey:@"ottTestParams"];
    [videoTestResultsDic setObject:_emptyArr forKey:@"resultList"];
    [videoTestResultsDic setObject:[NSNumber numberWithLongLong:_svTestId] forKey:@"sampleTime"];
    [videoTestResultsDic setObject:@0 forKey:@"samplingTimes"];
    [videoTestResultsDic setObject:@0 forKey:@"startTime"];
    [videoTestResultsDic setObject:@0 forKey:@"testId"];
    [videoTestResultsDic setObject:@0 forKey:@"totalDownloadSize"];
    [videoTestResultsDic setObject:@0 forKey:@"totalDownloadTime"];
    [videoTestResultsDic setObject:@0 forKey:@"totalPlayingByteNumber"];
    [videoTestResultsDic setObject:uvMOSScoreDic forKey:@"uvMOSScore"];
    [videoTestResultsDic setObject:cdnInfoArray forKey:@"cdnServerInfos"];

    return videoTestResultsDic;
}


- (NSMutableDictionary *)genWebTestResultsDic
{
    if (_webResultArray.count == 0)
    {
        needUploadLogFile = TRUE;
        return nil;
    }

    // 将结果的json字符串转换成对象
    NSError *error;
    SVDetailResultModel *model = [_webResultArray objectAtIndex:0];
    NSString *testResultString = model.testResult;
    id webTestResultJson =
    [NSJSONSerialization JSONObjectWithData:[testResultString dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0
                                      error:&error];

    // 解析明细结果
    NSMutableDictionary *totalResultDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *detailResultArray = [[NSMutableArray alloc] init];
    double sumResponseTime = 0.0;
    double sumDownloadSize = 0.0;
    double sumLoadTime = 0.0;
    double sumSpeed = 0.0;
    int sucessCount = 0;
    for (NSString *url in [webTestResultJson allKeys])
    {
        // 将json字符串转换成字典
        NSError *error;
        id currentResultJson = [NSJSONSerialization
        JSONObjectWithData:[[webTestResultJson objectForKey:url] dataUsingEncoding:NSUTF8StringEncoding]
                   options:0
                     error:&error];
        if (error)
        {
            SVError (@"%@", error);
            continue;
        }


        NSMutableDictionary *currentDic = [[NSMutableDictionary alloc] init];

        // 页面加载大小
        NSNumber *downloadSize = [self string2num:[currentResultJson valueForKey:@"downloadSize"]];
        [currentDic setObject:downloadSize forKey:@"downloadSize"];

        // 下载速度
        NSNumber *downloadSpeed =
        [self string2num:[currentResultJson valueForKey:@"downloadSpeed"]];
        [currentDic setObject:downloadSpeed forKey:@"downSpeed"];

        [currentDic setObject:[[NSNumber alloc] initWithInt:0] forKey:@"iconId"];

        // 完整下载时间
        NSNumber *totalTime = [self string2num:[currentResultJson valueForKey:@"totalTime"]];
        if (totalTime.floatValue < 0)
        {
            needUploadLogFile = TRUE;
        }

        double loadTime =
        [totalTime doubleValue] >= 0 ? [totalTime doubleValue] * 1000 : [totalTime doubleValue];
        [currentDic setObject:[[NSNumber alloc] initWithLong:loadTime] forKey:@"loadingTime"];

        [currentDic setObject:[[NSNumber alloc] initWithInt:100] forKey:@"progress"];

        // 响应时间
        NSNumber *responseTime = [self string2num:[currentResultJson valueForKey:@"responseTime"]];
        double resTime = [responseTime doubleValue] >= 0 ? [responseTime doubleValue] * 1000 :
                                                           [responseTime doubleValue];
        [currentDic setObject:[[NSNumber alloc] initWithLong:resTime] forKey:@"responseTime"];

        [currentDic setObject:[[NSNumber alloc] initWithInt:0] forKey:@"startLoadingUrlCount"];

        //判断是否测试成功
        if ([responseTime doubleValue] > 0 && [totalTime doubleValue] < 10)
        {
            [currentDic setObject:@YES forKey:@"responseTimeFinish"];
            [currentDic setObject:[[NSNumber alloc] initWithInt:0] forKey:@"status"];

            // 成功的数据记录下来，用于计算平均值
            sumDownloadSize += [downloadSize doubleValue];
            sumSpeed += [downloadSpeed doubleValue];
            sumLoadTime += [totalTime doubleValue];
            sumResponseTime += [responseTime doubleValue];
            sucessCount += 1;
        }
        else
        {
            [currentDic setObject:@NO forKey:@"responseTimeFinish"];
            [currentDic setObject:[[NSNumber alloc] initWithInt:-1] forKey:@"status"];
        }

        // 测试地址
        [currentDic setObject:url forKey:@"url"];

        [detailResultArray addObject:currentDic];
    }

    [totalResultDic setObject:[[NSNumber alloc] initWithLongLong:[model.ID longLongValue]]
                       forKey:@"testId"];
    [totalResultDic setObject:[[NSNumber alloc] initWithLongLong:[model.testId longLongValue]]
                       forKey:@"testId"];
    [totalResultDic setObject:[[NSNumber alloc] initWithInt:0] forKey:@"sampleTime"];

    // 只要有一个成功，就算成功
    if (sucessCount > 0)
    {
        [totalResultDic setObject:@"SUCCESS" forKey:@"completions"];
        [totalResultDic setObject:@"SUCCESS" forKey:@"resFlag"];
        [totalResultDic setObject:[[NSNumber alloc] initWithInt:0] forKey:@"resStatus"];
        [totalResultDic setObject:[[NSNumber alloc] initWithDouble:(sumSpeed / sucessCount)]
                           forKey:@"downloadSpeed"];
        [totalResultDic setObject:[[NSNumber alloc] initWithLong:((sumLoadTime * 1000) / sucessCount)]
                           forKey:@"openDuration"];
        [totalResultDic setObject:[[NSNumber alloc] initWithLong:((sumResponseTime * 1000) / sucessCount)]
                           forKey:@"responseTime"];
    }
    else
    {
        [totalResultDic setObject:@"FAILURE" forKey:@"completions"];
        [totalResultDic setObject:@"FAILURE" forKey:@"resFlag"];
        [totalResultDic setObject:[[NSNumber alloc] initWithInt:0] forKey:@"resStatus"];
        [totalResultDic setObject:[[NSNumber alloc] initWithInt:-1] forKey:@"downloadSpeed"];
        [totalResultDic setObject:[[NSNumber alloc] initWithInt:-1] forKey:@"openDuration"];
        [totalResultDic setObject:[[NSNumber alloc] initWithInt:-1] forKey:@"responseTime"];
    }
    [totalResultDic setObject:detailResultArray forKey:@"urlTestResList"];

    return totalResultDic;
}

// 将字符串转换为数字
- (NSNumber *)string2num:(NSString *)str
{
    if (!str)
    {
        return @0;
    }

    return [[NSNumber alloc] initWithDouble:[str doubleValue]];
}

// 将字符串转换为数字
- (NSNumber *)string2int:(NSString *)str
{
    if (!str)
    {
        return @0;
    }

    return [[NSNumber alloc] initWithInt:[str intValue]];
}


// 将字典转换成json字符串
- (NSString *)dictionaryToJsonString:(NSMutableDictionary *)dictionary
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error)
    {
        SVError (@"%@", error);
        return @"";
    }
    else
    {
        NSString *resultJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [resultJson stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    }
}

@end
