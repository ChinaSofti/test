//
//  SVResultPush.m
//  SpeedPro
//
//  Created by 李灏 on 16/3/13.
//  Copyright © 2016年 chinasofti. All rights reserved.
//


#import "SVResultPush.h"
#import <SPCommon/SVDBManager.h>
#import <SPCommon/SVHttpsGetter.h>
#import <SPService/SVIPAndISPGetter.h>
#import <SPService/SVProbeInfo.h>

@implementation SVResultPush

SVCurrentResultModel *_resultModel;

NSMutableData *_allData;

NSString *_urlString = @"https://58.60.106.188:12210/speedpro/results";

BOOL finished;

long _svTestId;
NSNumber *_svTestTime;


SVDBManager *_db;
NSArray *_videoResultArray;
NSArray *_webResultArray;
NSArray *_speedResultArray;

NSArray *_emptyArr;

- (void)queryResult
{
    sleep (2);

    // 拼写sql // 测试类型：0=video,1=web,2=speed
    NSMutableString *vsql = [NSMutableString
    stringWithFormat:@"select * from SVDetailResultModel where testId=%ld and testType=0", _svTestId];

    NSMutableString *wsql = [NSMutableString
    stringWithFormat:@"select * from SVDetailResultModel where testId=%ld and testType=1", _svTestId];

    NSMutableString *ssql = [NSMutableString
    stringWithFormat:@"select * from SVDetailResultModel where testId=%ld and testType=2", _svTestId];

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

- (id)initWithURLNSString:(NSString *)urlString testId:(NSNumber *)testId
{
    _svTestId = [testId longValue];
    _db = [SVDBManager sharedInstance];

    _emptyArr = [[NSArray alloc] init];

    // TODO yzy 测试时间
    _svTestTime = [[NSNumber alloc] initWithLong:(long)([[NSDate date] timeIntervalSince1970] * 1000)];

    [self queryResult];

    //_urlString = urlString;
    NSURL *url = [[NSURL alloc] initWithString:_urlString];

    return [self initWithURL:url];
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

    SVIPAndISP *isp = [SVIPAndISPGetter getIPAndISP];
    SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];

    NSMutableDictionary *locationDic = [[NSMutableDictionary alloc] init];
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

    // 1.2 param
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];

    // 手机别名: iPhone Simulator
    NSString *userPhoneName = [[UIDevice currentDevice] name];

    // 设备名称: iPhone OS
    NSString *deviceName = [[UIDevice currentDevice] systemName];

    // 手机系统版本: 9.2
    NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];

    // 手机型号: iPhone
    //    NSString *phoneModel = [[UIDevice currentDevice] model];

    // UUID
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSString *mobilename = [NSString stringWithFormat:@"%@ %@ %@", userPhoneName, deviceName, phoneVersion];

    [paramDic setObject:@0 forKey:@"cellid"];
    [paramDic setObject:uuid forKey:@"mobileid"];
    [paramDic setObject:[self ispFilter:isp str:isp.query] forKey:@"mobileip"];
    [paramDic setObject:mobilename forKey:@"mobilename"];
    [paramDic setObject:[self ispFilter:isp str:isp.isp] forKey:@"operatorname"];
    [paramDic setObject:!probeInfo.networkType ? @"" : probeInfo.networkType forKey:@"operatornw"];
    NSMutableDictionary *collectorResultsDic = [[NSMutableDictionary alloc] init];
    NSString *bw = [probeInfo getBandwidth];
    NSNumber *bwNumber = [NSNumber numberWithInt:[bw intValue]];
    [collectorResultsDic setObject:!bw ? @0 : bwNumber forKey:@"bandWidth"];
    NSString *bandwidthType = [probeInfo getBandwidthType];
    NSNumber *bandwidthTypeNumber = [NSNumber numberWithInt:[bandwidthType intValue]];
    [collectorResultsDic setObject:bandwidthTypeNumber forKey:@"bandwidthType"];
    [collectorResultsDic setObject:@"SUCCESS" forKey:@"completions"];
    [collectorResultsDic setObject:@0 forKey:@"id"];
    [collectorResultsDic setObject:locationDic forKey:@"location"];
    [collectorResultsDic setObject:@1 forKey:@"networktype"];
    [collectorResultsDic setObject:paramDic forKey:@"param"];
    [collectorResultsDic setObject:@0 forKey:@"sampleTime"];
    [collectorResultsDic setObject:@0 forKey:@"signalStrength"];
    [collectorResultsDic setObject:@0 forKey:@"SNR"];
    [collectorResultsDic setObject:@0 forKey:@"testId"];
    [collectorResultsDic setObject:_svTestTime forKey:@"testTime"];

    return collectorResultsDic;
}

- (NSMutableDictionary *)genSpeedTestResultsDic
{
    // 2. speedTestResults
    // 2.1 location
    //[testResultJson valueForKey:@"downloadSpeed"];

    SVDetailResultModel *model = [_speedResultArray objectAtIndex:0];
    NSString *testResult = model.testResult;
    NSError *error;
    id speedTestResultJson =
    [NSJSONSerialization JSONObjectWithData:[testResult dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0
                                      error:&error];

    NSMutableDictionary *locationDic = [[NSMutableDictionary alloc] init];
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

    // 2.2 upAverage
    NSMutableDictionary *upAverageDic = [[NSMutableDictionary alloc] init];
    [upAverageDic setObject:@"SUCCESS" forKey:@"completions"];
    [upAverageDic setObject:@0 forKey:@"id"];
    [upAverageDic setObject:@1 forKey:@"isAverage"];
    [upAverageDic setObject:@0 forKey:@"isUpload"];
    [upAverageDic setObject:@1457841583057 forKey:@"sampleTime"];
    NSNumber *upSpeed =
    [[NSNumber alloc] initWithLong:[[speedTestResultJson valueForKey:@"uploadSpeed"] longValue]];
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
    [[NSNumber alloc] initWithLong:[[speedTestResultJson valueForKey:@"downloadSpeed"] longValue]];
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

    NSMutableDictionary *vtLocationDic = [[NSMutableDictionary alloc] init];
    //    SVIPAndISP *videoIsp = [SVIPAndISPGetter getIPAndISP];
    [vtLocationDic setObject:@"" forKey:@"as"];
    [vtLocationDic setObject:@"" forKey:@"carrier"];
    [vtLocationDic setObject:@"" forKey:@"city"];
    [vtLocationDic setObject:@"" forKey:@"country"];
    [vtLocationDic setObject:@"" forKey:@"countryCode"];
    [vtLocationDic setObject:@"" forKey:@"district"];
    [vtLocationDic setObject:@"" forKey:@"ip"];
    [vtLocationDic setObject:@"" forKey:@"isp"];
    [vtLocationDic setObject:@"" forKey:@"lat"];
    [vtLocationDic setObject:@"" forKey:@"lon"];
    [vtLocationDic setObject:@"" forKey:@"message"];
    [vtLocationDic setObject:@"" forKey:@"org"];
    [vtLocationDic setObject:@"" forKey:@"province"];
    [vtLocationDic setObject:@"" forKey:@"query"];
    [vtLocationDic setObject:@"" forKey:@"region"];
    [vtLocationDic setObject:@"" forKey:@"regionName"];
    [vtLocationDic setObject:@"success" forKey:@"status"];
    [vtLocationDic setObject:@"" forKey:@"timezone"];
    [vtLocationDic setObject:@"" forKey:@"zip"];

    // 3.2 mediaInput
    NSMutableDictionary *mediaInputDic = [[NSMutableDictionary alloc] init];
    [mediaInputDic
    setObject:[self string2num:[videoTestContextJson valueForKey:@"videoSegementBitrate"]]
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
    [mediaInputDic setObject:@0.0 forKey:@"periodAvgVideoBitrate"];
    [mediaInputDic setObject:@0.0 forKey:@"playTotalTime"];
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
    [ottTestParamsDic setObject:@0 forKey:@"testDuration"];
    [ottTestParamsDic setObject:[videoTestContextJson valueForKey:@"videoURL"] forKey:@"testUrl"];
    [ottTestParamsDic setObject:@"" forKey:@"userName"];
    [ottTestParamsDic setObject:@"" forKey:@"videoServerIp"];
    [ottTestParamsDic setObject:@80 forKey:@"videoServerPort"];
    [ottTestParamsDic setObject:@0 forKey:@"videoSize"];
    [ottTestParamsDic setObject:@"MP4" forKey:@"videoType"];
    [ottTestParamsDic setObject:@"" forKey:@"videoUrl"];

    // 3.4 uvMOSScore
    NSMutableDictionary *uvMOSScoreDic = [[NSMutableDictionary alloc] init];
    [uvMOSScoreDic setObject:@0.0 forKey:@"satCurUvmos"];
    [uvMOSScoreDic setObject:[self string2num:[videoTestResultJson valueForKey:@"sQualitySession"]]
                      forKey:@"satSequenceSquality"];
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
    [videoTestResultsDic setObject:@0.0 forKey:@"aveBitRate"];
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
    [videoTestResultsDic setObject:vtLocationDic forKey:@"location"];
    [videoTestResultsDic setObject:mediaInputDic forKey:@"mediaInput"];
    [videoTestResultsDic setObject:ottTestParamsDic forKey:@"ottTestParams"];
    [videoTestResultsDic setObject:_emptyArr forKey:@"resultList"];
    [videoTestResultsDic setObject:_svTestTime forKey:@"sampleTime"];
    [videoTestResultsDic setObject:@0 forKey:@"samplingTimes"];
    [videoTestResultsDic setObject:@0 forKey:@"startTime"];
    [videoTestResultsDic setObject:@0 forKey:@"testId"];
    [videoTestResultsDic setObject:@0 forKey:@"totalDownloadSize"];
    [videoTestResultsDic setObject:@0 forKey:@"totalDownloadTime"];
    [videoTestResultsDic setObject:@0 forKey:@"totalPlayingByteNumber"];
    [videoTestResultsDic setObject:uvMOSScoreDic forKey:@"uvMOSScore"];

    return videoTestResultsDic;
}


- (NSMutableDictionary *)genWebTestResultsDic
{

    // 4. webTestResults
    // 4.1 urlTestResList

    //    NSMutableArray *urlTestResList = [NSMutableArray arrayWithCapacity:5];
    //
    //    NSMutableDictionary *urlTestResDic = [[NSMutableDictionary alloc] init];
    //    [urlTestResDic setObject:@1124235 forKey:@"downloadSize"];
    //    [urlTestResDic setObject:@-1.0 forKey:@"downSpeed"];
    //    [urlTestResDic setObject:@0 forKey:@"iconId"];
    //    [urlTestResDic setObject:@-1 forKey:@"loadingTime"];
    //    [urlTestResDic setObject:@100 forKey:@"progress"];
    //    [urlTestResDic setObject:@-1 forKey:@"responseTime"];
    //    [urlTestResDic setObject:@true forKey:@"responseTimeFinish"];
    //    [urlTestResDic setObject:@0 forKey:@"startLoadingUrlCount"];
    //    [urlTestResDic setObject:@-1 forKey:@"status"];
    //    [urlTestResDic setObject:@"http://www.yahoo.com" forKey:@"url"];
    //    [urlTestResList addObject:urlTestResDic];
    //
    //    NSMutableDictionary *webTestResultsDic = [[NSMutableDictionary alloc] init];
    //    [webTestResultsDic setObject:@"SUCCESS" forKey:@"completions"];
    //    [webTestResultsDic setObject:@1931.1074 forKey:@"downloadSpeed"];
    //    [webTestResultsDic setObject:@0 forKey:@"id"];
    //    [webTestResultsDic setObject:@1537 forKey:@"openDuration"];
    //    [webTestResultsDic setObject:@"SUCCESS" forKey:@"resFlag"];
    //    [webTestResultsDic setObject:@798 forKey:@"responseTime"];
    //    [webTestResultsDic setObject:@0 forKey:@"resStatus"];
    //    [webTestResultsDic setObject:@0 forKey:@"sampleTime"];
    //    [webTestResultsDic setObject:@0 forKey:@"testId"];
    //    [webTestResultsDic setObject:urlTestResList forKey:@"urlTestResList"];

    return nil;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

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
        SVError (@"genCollectorResultsDic error! %@", e);
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


    SVInfo (@"json = %@", [self dictionaryToJsonString:dic]);

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];

    //    if (dic)
    //    {
    //        return nil;
    //    }
    // 连接服务器发送请求
    [NSURLConnection
    sendAsynchronousRequest:request
                      queue:[[NSOperationQueue alloc] init]
          completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

            if (connectionError)
            {
                SVError (@"result push error:%@", connectionError);
                return;
            }

            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SVInfo (@"result push success %@", result);
          }];

    return self;
}

- (NSNumber *)string2num:(NSString *)str
{
    if (!str)
    {
        return @0;
    }

    return [[NSNumber alloc] initWithDouble:[str doubleValue]];
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

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error)
    {
        SVError (@"request URL:%@ fail.  Error:%@", _urlString, error);
        finished = true;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data)
    {
        if (!_allData)
        {
            _allData = [[NSMutableData alloc] init];
        }

        [_allData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_allData)
    {
        NSLog (@"request finished. data length:%ld", _allData.length);
    }
    else
    {
        NSLog (@"request finished. data length:0");
    }

    finished = true;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
         forAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

@end
