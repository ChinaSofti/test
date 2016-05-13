//
//  SVIPAndISPGetter2.m
//  SpeedPro
//
//  Created by Rain on 4/29/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVHttpGetter.h"
#import "SVIPAndISP.h"
#import "SVIPAndISPGetter.h"
#import "SVProbeInfo.h"
#import "SVSpeedTestServers.h"

@implementation SVIPAndISPGetter
{
    // 缓存IP归属地信息
    NSMutableDictionary *ipAndISPCacheDic;

    // 本机IP和运营商信息
    SVIPAndISP *localIPAndISP;

    // 经度
    NSString *lat;

    // 纬度
    NSString *lon;
}

// 查询本机归属地信息的URL，国外首选方案
static NSString *LOCATION_FROM_IPA_API_URL = @"http://%@/json?lang=%@";

// 查询指定ip归属地信息的URL，国外首选方案
static NSString *IP_LOCATION_FROM_IPA_API_URL = @"http://%@/json/%@?lang=%@";

// 查询本机归属地信息的URL，国内首选方案，国外备选方案
static NSString *LOCATION_FROM_BAIDU_URL =
@"http://api.map.baidu.com/location/ip?ak=k38rQGnU2ZIAGAGSGwrxdCtIFE74lvjp&coor=bd09ll";
static NSString *IP_LOCATION_FROM_BAIDU_URL =
@"http://api.map.baidu.com/location/ip?ak=k38rQGnU2ZIAGAGSGwrxdCtIFE74lvjp&coor=bd09ll&ip=%@";

// 查询指定ip归属地信息的URL，国内首选方案，国外备选方案
static NSString *LOCATION_FROM_TAOBAO_URL = @"http://ip.taobao.com/service/getIpInfo.php?ip=myip";
static NSString *IP_LOCATION_FROM_TAOBAO_URL = @"http://ip.taobao.com/service/getIpInfo.php?ip=%@";

// 查询国家码和经纬度的URL
static NSString *LOCATION_FROM_GEOIPTOOL_URL = @"https://geoiptool.com/api/view";
static NSString *IP_LOCATION_FROM_GEOIPTOOL_URL = @"https://geoiptool.com/api/view?ip=%@";

// 查询国家码和经纬度的备选URL
static NSString *LOCATION_FROM_GEOIP_URL = @"http://geoip.nekudo.com/api";
static NSString *IP_LOCATION_FROM_GEOIP_URL = @"http://geoip.nekudo.com/api/%@";

// 默认语言
static NSString *DEFAULT_EN_US_LANG = @"en";

// ipa-api域名IP的数组
static NSArray *ipArray;

/**
 *  单例对象
 *
 *  @return 单例对象
 */
+ (id)sharedInstance
{
    static SVIPAndISPGetter *ipAndISPGetter;
    @synchronized (self)
    {
        if (ipAndISPGetter == nil)
        {
            ipAndISPGetter = [[super allocWithZone:NULL] init];
        }

        if (ipArray == nil)
        {
            ipArray = @[@"192.211.58.117", @"162.250.144.215"];
        }
    }

    return ipAndISPGetter;
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
    return [SVIPAndISPGetter sharedInstance];
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
    return [SVIPAndISPGetter sharedInstance];
}

/**
 *  获取本机IP，归属地，运营商等信息
 *
 *  @return TSIPAndISP 本机IP，归属地，运营商等信息
 */
- (SVIPAndISP *)getIPAndISP
{
    if (localIPAndISP)
    {
        return localIPAndISP;
    }

    /**
     * 首先判断国家，如果是国内则使用淘宝方案获取IP信息，如果是国外则使用ipa-api方案获取
     */
    //    SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
    //    if (servers.isp && [servers.isp containsString:@"China"])
    //    {
    //        // 使用备选方案
    //        localIPAndISP = [self bakIpInfoWithIp:nil];
    //    }
    //    else
    //    {

    // 使用首选方案获取IP信息
    localIPAndISP = [self ipInfoWithIp:nil];

    // 如果首选方案获取失败，则使用备选方案
    if (!localIPAndISP)
    {
        // 使用备选方案
        localIPAndISP = [self bakIpInfoWithIp:nil];
    }
    //    }

    // 如果localIPAndISP存在,给SVProbeInfo的isp赋值为localIPAndISP.isp
    if (localIPAndISP)
    {
        SVProbeInfo *probeInfo = [SVProbeInfo sharedInstance];
        probeInfo.isp = localIPAndISP.isp;
    }
    return localIPAndISP;
}

/**
 *  根据IP查询归属地和运营商等信息。目前只支持两种语言的返回结果，英文和中文。缺省采用系统语言进行查询，并返回结果
 *
 *  @param ip IP地址
 *
 *  @return IP归属地
 */
- (SVIPAndISP *)queryIPDetail:(NSString *)ip
{
    SVIPAndISP *ipAndISP = nil;
    @synchronized (self)
    {
        if (!ipAndISPCacheDic)
        {
            ipAndISPCacheDic = [[NSMutableDictionary alloc] init];
        }

        ipAndISP = [ipAndISPCacheDic valueForKey:ip];
    }

    if (ipAndISP)
    {
        return ipAndISP;
    }

    // 使用首选方案获取IP信息
    ipAndISP = [self ipInfoWithIp:ip];

    // 如果首选方案获取失败，则使用备选方案
    if (!ipAndISP)
    {
        // 使用备选方案
        ipAndISP = [self bakIpInfoWithIp:ip];
    }

    @synchronized (self)
    {
        SVIPAndISP *cacheIPAndISP = [ipAndISPCacheDic valueForKey:ip];
        if (!cacheIPAndISP && ipAndISP)
        {
            [ipAndISPCacheDic setObject:ipAndISP forKey:ip];
        }
    }

    return ipAndISP;
}


/**
 * 获取指定IP的相关信息
 * @param ip 指定的IP
 * @return IP归属地信息
 */
- (SVIPAndISP *)ipInfoWithIp:(NSString *)ip
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

    // 生成随机数
    int randomIndex = arc4random () % [ipArray count];

    // 查询IP地址信息的json数据
    NSDictionary *dictionay = nil;
    if (!ip)
    {
        SVInfo (@"query ip and isp of this iphone, and return value with %@ language", lang);
        dictionay = [self
        queryIpInfoWithUrl:[NSString stringWithFormat:LOCATION_FROM_IPA_API_URL, ipArray[randomIndex], lang]
               WithTimeOut:5];
    }
    else
    {
        SVInfo (@"query ip[%@] location, and return value with %@ language", ip, lang);
        dictionay = [self queryIpInfoWithUrl:[NSString stringWithFormat:IP_LOCATION_FROM_IPA_API_URL,
                                                                        ipArray[randomIndex], ip, lang]
                                 WithTimeOut:5];
    }

    if (!dictionay)
    {
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
- (SVIPAndISP *)bakIpInfoWithIp:(NSString *)ip
{
    // 查询经纬度信息
    [self queryLatAndLonWithIp:ip];

    // 查询IP地址信息的json数据
    NSDictionary *ipInfoDic = nil;
    if (!ip)
    {
        SVInfo (@"query ip and isp of this iphone");
        ipInfoDic = [self queryIpInfoWithUrl:LOCATION_FROM_TAOBAO_URL WithTimeOut:5];
    }
    else
    {
        SVInfo (@"query ip[%@] location", ip);
        ipInfoDic = [self queryIpInfoWithUrl:[NSString stringWithFormat:IP_LOCATION_FROM_TAOBAO_URL, ip]
                                 WithTimeOut:5];
    }

    if (!ipInfoDic)
    {
        return nil;
    }

    // 解析出需要的数据
    SVIPAndISP *ipAndISP = [[SVIPAndISP alloc] init];
    [ipAndISP setAs:@""];
    [ipAndISP setZip:@""];
    [ipAndISP setQuery:[[ipInfoDic valueForKey:@"data"] valueForKey:@"ip"]];
    [ipAndISP setLat:lat];
    [ipAndISP setLon:lon];

    [ipAndISP setCountry:[[ipInfoDic valueForKey:@"data"] valueForKey:@"country"]];
    [ipAndISP setCountryCode:[[ipInfoDic valueForKey:@"data"] valueForKey:@"country_id"]];
    [ipAndISP setIsp:[[ipInfoDic valueForKey:@"data"] valueForKey:@"isp"]];
    [ipAndISP setCity:[[ipInfoDic valueForKey:@"data"] valueForKey:@"city"]];
    [ipAndISP setRegion:[[ipInfoDic valueForKey:@"data"] valueForKey:@"region_id"]];
    [ipAndISP setTimezone:@""];
    [ipAndISP setOrg:[[ipInfoDic valueForKey:@"data"] valueForKey:@"isp"]];
    [ipAndISP setRegionName:[[ipInfoDic valueForKey:@"data"] valueForKey:@"region"]];
    [ipAndISP setStatus:@"0"];

    SVDebug (@"return ipAndISP [as:%@  zip:%@  query:%@  lat:%@  lon:%@  country:%@  "
             @"countryCode:%@  "
             @"isp:%@  city:%@  region:%@   timezone:%@  org:%@   regionName:%@   status:%@]",
             ipAndISP.as, ipAndISP.zip, ipAndISP.query, ipAndISP.lat, ipAndISP.lon,
             ipAndISP.country, ipAndISP.countryCode, ipAndISP.isp, ipAndISP.city, ipAndISP.region,
             ipAndISP.timezone, ipAndISP.org, ipAndISP.regionName, ipAndISP.status);

    return ipAndISP;
}

/**
 *  根据指定的ip查询经纬度
 *
 */
- (void)queryLatAndLonWithIp:(NSString *)ip
{
    // 如果ip为空，则说明查询的是本机
    if (!ip)
    {
        SVSpeedTestServers *servers = [SVSpeedTestServers sharedInstance];
        lat = servers.lat;
        lon = servers.lon;
        return;
    }

    // 使用百度的方案查询经纬度，如果成功则返回
    if ([self queryLatAndLonByBaidu:ip])
    {
        return;
    }

    // 如果上述方案失败，则使用geoiptool的方案来查询经纬度
    if ([self queryLatAndLonByGeoiptool:ip])
    {
        return;
    }

    // 如果上述方案失败，则使用geoip的方案来查询经纬度
    if ([self queryLatAndLonByGeoip:ip])
    {
        return;
    }

    // 如果上述所有方案都失败，则默认为空
    lat = @"";
    lon = @"";
}

/**
 *  使用百度的方式获取经纬度
 */
- (BOOL)queryLatAndLonByBaidu:(NSString *)ip
{
    // 访问百度的查询地址，获取json数据
    NSDictionary *dictionay =
    [self queryIpInfoWithUrl:[NSString stringWithFormat:IP_LOCATION_FROM_BAIDU_URL, ip]
                 WithTimeOut:5];
    if (!dictionay)
    {
        return NO;
    }

    // 获取经纬度
    NSDictionary *content = [dictionay valueForKey:@"content"];
    NSDictionary *ponit = [content valueForKey:@"point"];
    lat = [ponit valueForKey:@"x"];
    lon = [ponit valueForKey:@"y"];

    return YES;
}

/**
 *  使用GEOIPTOOL的方式获取经纬度
 */
- (BOOL)queryLatAndLonByGeoiptool:(NSString *)ip
{
    // 访问GEOIPTOOL的查询地址，获取经纬度信息
    NSDictionary *dictionay =
    [self queryIpInfoWithUrl:[NSString stringWithFormat:IP_LOCATION_FROM_GEOIPTOOL_URL, ip]
                 WithTimeOut:5];
    if (!dictionay)
    {
        return NO;
    }

    // 获取经纬度
    lat = [dictionay valueForKey:@"latitude"];
    lon = [dictionay valueForKey:@"longitude"];
    return YES;
}

/**
 *  使用GEOIP的方式获取经纬度
 */
- (BOOL)queryLatAndLonByGeoip:(NSString *)ip
{
    // 访问GEOIPTOOL的查询地址，获取经纬度信息
    NSDictionary *dictionay =
    [self queryIpInfoWithUrl:[NSString stringWithFormat:IP_LOCATION_FROM_GEOIP_URL, ip]
                 WithTimeOut:5];
    if (!dictionay)
    {
        return NO;
    }

    // 获取经纬度
    NSDictionary *location = [dictionay valueForKey:@"location"];
    lat = [location valueForKey:@"latitude"];
    lon = [location valueForKey:@"longitude"];
    return YES;
}

/**
 *  获取经纬度的json字符串
 */
- (NSDictionary *)queryIpInfoWithUrl:(NSString *)url WithTimeOut:(int)timeout
{
    // 访问百度的查询地址，获取json数据
    NSData *jsonData = nil;
    @try
    {
        SVInfo (@"query ip and isp information, URL:%@", url);
        jsonData = [SVHttpGetter requestDataWithoutParameter:url WithTimeOut:timeout];
    }
    @catch (NSException *exception)
    {
        SVError (@"query ip and isp information fail. URL:%@. exception:%@", url, exception);
        return nil;
    }

    if (!jsonData)
    {
        SVError (@"ip and isp information is nil. URL:%@.", url);
        return nil;
    }

    // 将json数据转换为字典
    NSError *error;
    NSDictionary *dictionay =
    [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error)
    {
        SVError (@"query ip and isp information fail. URL:%@. Error:%@", url, error);
        return nil;
    }

    return dictionay;
}

@end
