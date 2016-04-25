//
//  TSIPAndISPGetter.m
//  TaskService
//
//  Created by Rain on 1/27/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVHttpGetter.h"
#import "SVI18N.h"
#import "SVIPAndISPGetter.h"
#import "SVLog.h"
#import "SVSpeedTestServers.h"

@implementation SVIPAndISPGetter
{
    //    TSIPAndISP *ipAndISP;
}

static NSString *defaultURL = @"http://ip-api.com/json?lang=%@";

static NSString *queryIPLocationURL = @"http://ip-api.com/json/%@?lang=%@";

static NSString *bakDefaultURL =
@"http://api.map.baidu.com/location/ip?ak=k38rQGnU2ZIAGAGSGwrxdCtIFE74lvjp&coor=bd09ll";

static NSString *bakDefaultIpInfoURL = @"http://ip.taobao.com/service/getIpInfo.php?ip=myip";

static NSString *bakQueryIPLocationURL =
@"http://api.map.baidu.com/location/ip?ak=k38rQGnU2ZIAGAGSGwrxdCtIFE74lvjp&coor=bd09ll&ip=%@";

static NSString *bakQueryIPInfoURL = @"http://ip.taobao.com/service/getIpInfo.php?ip=%@";


static NSString *DEFAULT_ZH_CN_LANG = @"zh-CN";

static NSString *DEFAULT_EN_US_LANG = @"en";

static SVIPAndISP *localIPAndISP;

+ (SVIPAndISP *)getIPAndISP
{
    if (localIPAndISP)
    {
        return localIPAndISP;
    }

    localIPAndISP = [SVIPAndISPGetter queryIPDetail:nil];
    return localIPAndISP;
}


/**
 *  根据IP查询归属地。目前只支持两种语言的返回结果，英文和中文。缺省采用系统语言进行查询，并返回结果
 *
 *  @param ip IP地址
 *
 *  @return IP归属地
 */
+ (SVIPAndISP *)queryIPDetail:(NSString *)ip
{
    // 使用首选方案获取IP信息
    SVIPAndISP *ipInfo = [self ipInfoWithIp:ip];

    // 如果首选方案获取失败，则使用备选方案
    if (!ipInfo)
    {
        // 使用备选方案
        ipInfo = [self bakIpInfoWithIp:ip];
    }

    // 如果备选方案还是没有结果则返回空
    if (!ipInfo)
    {
        return nil;
    }

    if (!localIPAndISP)
    {
        SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
        NSString *localIP = servers.clientIP;
        if ([ip isEqualToString:localIP])
        {
            localIPAndISP = ipInfo;
        }
    }

    return ipInfo;
}

/**
 * 获取指定IP的相关信息
 * @param ip 指定的IP
 * @return IP归属地信息
 */
+ (SVIPAndISP *)ipInfoWithIp:(NSString *)ip
{
    // 获取系统语言
    //    SVI18N *i18n = [SVI18N sharedInstance];
    //    NSString *lang = [i18n getLanguage];
    //    if ([lang containsString:@"en"])
    //    {
    //        lang = DEFAULT_EN_US_LANG;
    //    }
    //    else
    //    {
    //        lang = DEFAULT_ZH_CN_LANG;
    //    }

    NSString *lang = DEFAULT_EN_US_LANG;

    // 查询IP地址信息的json数据
    NSData *jsonData = nil;
    @try
    {
        if (!ip)
        {
            SVInfo (@"query ip and isp of this iphone, and return value with %@ language", lang);
            jsonData =
            [SVHttpGetter requestDataWithoutParameter:[NSString stringWithFormat:defaultURL, lang]];
        }
        else
        {
            SVInfo (@"query ip[%@] location, and return value with %@ language", ip, lang);
            jsonData = [SVHttpGetter
            requestDataWithoutParameter:[NSString stringWithFormat:queryIPLocationURL, ip, lang]];
        }
    }
    @catch (NSException *exception)
    {
        SVError (@"query ip and isp information fail. exception:%@", exception);
        return nil;
    }

    if (!jsonData)
    {
        return nil;
    }

    // 将json数据转换为字典
    NSError *error;
    NSDictionary *dictionay =
    [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error)
    {
        SVError (@"query ip[%@] location fail. Error:%@", ip, error);
        return nil;
    }

    SVIPAndISP *ipAndISP = [[SVIPAndISP alloc] init];
    [ipAndISP setAs:[dictionay valueForKey:@"as"]];
    [ipAndISP setZip:[dictionay valueForKey:@"zip"]];
    [ipAndISP setQuery:[dictionay valueForKey:@"query"]];
    [ipAndISP setLat:[dictionay valueForKey:@"lat"]];
    [ipAndISP setLon:[dictionay valueForKey:@"lon"]];
    [ipAndISP setCountry:[dictionay valueForKey:@"country"]];
    [ipAndISP setCountryCode:[dictionay valueForKey:@"countryCode"]];
    [ipAndISP setIsp:[dictionay valueForKey:@"isp"]];
    [ipAndISP setCity:[dictionay valueForKey:@"city"]];
    [ipAndISP setRegion:[dictionay valueForKey:@"region"]];
    [ipAndISP setTimezone:[dictionay valueForKey:@"timezone"]];
    [ipAndISP setOrg:[dictionay valueForKey:@"org"]];
    [ipAndISP setRegionName:[dictionay valueForKey:@"regionName"]];
    [ipAndISP setStatus:[dictionay valueForKey:@"status"]];

    SVDebug (@"return ipAndISP [as:%@  zip:%@  query:%@  lat:%@  lon:%@  country:%@  "
             @"countryCode:%@  "
             @"isp:%@  city:%@  region:%@   timezone:%@  org:%@   regionName:%@   status:%@]",
             ipAndISP.as, ipAndISP.zip, ipAndISP.query, ipAndISP.lat, ipAndISP.lon,
             ipAndISP.country, ipAndISP.countryCode, ipAndISP.isp, ipAndISP.city, ipAndISP.region,
             ipAndISP.timezone, ipAndISP.org, ipAndISP.regionName, ipAndISP.status);

    return ipAndISP;
}

/**
 * 获取指定IP的相关信息(备用方案)
 * @param ip 指定的IP
 * @return IP归属地信息
 */
+ (SVIPAndISP *)bakIpInfoWithIp:(NSString *)ip
{
    // 查询IP地址信息的json数据
    NSData *jsonData = nil;
    NSData *ipInfoData = nil;
    @try
    {
        if (!ip)
        {
            SVInfo (@"query ip and isp of this iphone");
            jsonData = [SVHttpGetter requestDataWithoutParameter:bakDefaultURL];
            ipInfoData = [SVHttpGetter requestDataWithoutParameter:bakDefaultIpInfoURL];
        }
        else
        {
            SVInfo (@"query ip[%@] location", ip);
            jsonData = [SVHttpGetter
            requestDataWithoutParameter:[NSString stringWithFormat:bakQueryIPLocationURL, ip]];
            ipInfoData =
            [SVHttpGetter requestDataWithoutParameter:[NSString stringWithFormat:bakQueryIPInfoURL, ip]];
        }
    }
    @catch (NSException *exception)
    {
        SVError (@"query ip and isp information fail. exception:%@", exception);
        return nil;
    }

    if (!jsonData || !ipInfoData)
    {
        return nil;
    }

    // 将json数据转换为字典
    NSError *error;
    NSMutableDictionary *dictionay =
    [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error)
    {
        SVError (@"query ip[%@] location fail. Error:%@", ip, error);
        return nil;
    }

    NSDictionary *ipInfoDic =
    [NSJSONSerialization JSONObjectWithData:ipInfoData options:0 error:&error];
    if (error)
    {
        SVError (@"query ip[%@] info fail. Error:%@", ip, error);
        return nil;
    }

    SVIPAndISP *ipAndISP = [[SVIPAndISP alloc] init];
    [ipAndISP setAs:@""];
    [ipAndISP setZip:@""];
    [ipAndISP setQuery:[[ipInfoDic valueForKey:@"data"] valueForKey:@"ip"]];

    // 获取经纬度
    NSDictionary *content = [dictionay valueForKey:@"content"];
    NSDictionary *ponit = [content valueForKey:@"point"];
    [ipAndISP setLat:[ponit valueForKey:@"y"]];
    [ipAndISP setLon:[ponit valueForKey:@"x"]];

    [ipAndISP setCountry:[[ipInfoDic valueForKey:@"data"] valueForKey:@"country"]];
    [ipAndISP setCountryCode:[[ipInfoDic valueForKey:@"data"] valueForKey:@"country_id"]];
    [ipAndISP setIsp:[[ipInfoDic valueForKey:@"data"] valueForKey:@"isp"]];
    [ipAndISP setCity:[[ipInfoDic valueForKey:@"data"] valueForKey:@"city"]];
    [ipAndISP setRegion:[[ipInfoDic valueForKey:@"data"] valueForKey:@"region_id"]];
    [ipAndISP setTimezone:@""];
    [ipAndISP setOrg:[[ipInfoDic valueForKey:@"data"] valueForKey:@"isp"]];
    [ipAndISP setRegionName:[[ipInfoDic valueForKey:@"data"] valueForKey:@"region"]];
    [ipAndISP setStatus:[dictionay valueForKey:@"status"]];

    SVDebug (@"return ipAndISP [as:%@  zip:%@  query:%@  lat:%@  lon:%@  country:%@  "
             @"countryCode:%@  "
             @"isp:%@  city:%@  region:%@   timezone:%@  org:%@   regionName:%@   status:%@]",
             ipAndISP.as, ipAndISP.zip, ipAndISP.query, ipAndISP.lat, ipAndISP.lon,
             ipAndISP.country, ipAndISP.countryCode, ipAndISP.isp, ipAndISP.city, ipAndISP.region,
             ipAndISP.timezone, ipAndISP.org, ipAndISP.regionName, ipAndISP.status);

    return ipAndISP;
}

@end
