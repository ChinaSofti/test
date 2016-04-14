//=======================================================================================
//                 点量软件，致力于做最专业的通用软件库，节省您的开发时间
//
//	Copyright:	Copyright (c) Peng Zhang
//  版权所有：	点量软件有限公司 (QQ:52401692)
//
//              如果您是个人作为非商业目的使用，您可以自由、免费的使用点量软件库和演示程序，
//              也期待收到您反馈的意见和建议，共同改进点量产品
//              如果您是商业使用，那么您需要联系作者申请产品的商业授权。
//              点量软件库所有演示程序的代码对外公开，软件库的代码只限付费用户个人使用。
//
//  官方网站：  http://www.dolit.cn http://blog.dolit.cn
//
//=======================================================================================

#ifndef DOLIT_CN_VIDEO_PARSER_INC_H_INCLUDED
#define DOLIT_CN_VIDEO_PARSER_INC_H_INCLUDED

#pragma once
// 包含一些类型定义
typedef unsigned long long UINT64;

#ifdef WIN32
#ifdef DLVIDEOPARSER_EXPORTS
#define DLVideo_API extern _declspec(dllexport)
#pragma message("--- EXPORT DOLIT_VIDEO_PARSER Library  ...")
#else
#define DLVideo_API extern _declspec(dllimport)
#pragma message("--- IMPORT DOLIT_VIDEO_PARSER Library  ...")
#endif
#else // WIN32
#define DLVideo_API extern
#define WINAPI
#ifdef __APPLE__
#ifndef _HAVE_IOS_BASE_
typedef unsigned long DWORD;
typedef long HRESULT;
#endif
#endif
#endif

/// ==================================================================
///  以下是一些结构体信息
/// ==================================================================

//以下信息并不是所有网站都有，比如优酷就没有提供frameCount这个信息。
// 记录一个单段文件的信息，网址和时长、大小等

#pragma pack(push, old_value) // 保存VC++编译器结构对齐字节数
#pragma pack(4) // 设置为以一字节对齐。

typedef struct
{
    UINT64 fileSize; //这一段文件的大小，如果为0，则说明目标网站没返回单段的大小，可以在下载时，通过Http协议再去获取大小。
    int seconds; //这一段视频文件的时长，有个别网站也有可能这里返回的时长都一样的（是因为他返回的是总时长）
    int fileNO; //这一段的序号，从0开始，比如0 1 2……。
    //代表分段的先后顺序。有些网站，视频是不分段的，
    //但对某一种视频格式（比如高清，也给了两段地址，我们这里标注的序号都是0，两段都是0。这种就是说：这两段并不是一个先后顺序，而是代表这个视频可以随机选一个播放，这种其实还是单段视频）
    char *url; // 该段视频的实际地址（可播放和可下载的地址）
} VideoSeg;

#pragma pack(pop, old_value)

// 记录某一种类型的文件信息，比如flv、mp4、hd2……（高清、标清等）
#pragma pack(push, old_value) // 保存VC++编译器结构对齐字节数
#pragma pack(4) // 设置为以一字节对齐。
typedef struct
{
    char *strType; //本组视频的类型字符，不同网站服务器返回的类型名称不同。比如优酷是flv、mp4.但有些可能就是直接返回SD、HD……，土豆还有P360/P720之类的不同称呼。

    //视频可能切分了很多段，所有段的信息
    int segCount; // 分段的数目
    VideoSeg *segs; // 分段的数组，每个元素代表一个分段，详细请参考VideoSeg
} VideoInType;
#pragma pack(pop, old_value)

// 记录视频结果中是否还有关联地址 --
// 比如这个电影还有粤语版，粤语版的网址是……，用户可以通过关联地址再去解析其它语言版本的视频
#pragma pack(push, old_value) // 保存VC++编译器结构对齐字节数
#pragma pack(4) // 设置为以一字节对齐。
typedef struct
{
    char *strType; //本地址的描述
    char *url; //地址
} RelatedWebUrl;
#pragma pack(pop, old_value)

// 记录解析出的视频基本信息

#pragma pack(push, old_value) // 保存VC++编译器结构对齐字节数
#pragma pack(4) // 设置为以一字节对齐。

enum VideoSiteID
{
    VSite_UnSupported = 0, //未知的视频网站（我们还未支持的视频网站）
    VSite_Sina, // sina视频和播客  示例：http://video.sina.com.cn/m/wzyjr_61908909.html
    VSite_Youku, //优酷            示例：http://v.youku.com/v_show/id_XMjY0NDI2MzA4.html
    VSite_Youtube, // youtube（需要本机能翻墙正常访问youtube）
    // 示例：http://www.youtube.com/watch?v=DKvIjO_Aidc&feature=topvideos
    VSite_Tudou, //土豆            示例：http://www.tudou.com/albumplay/m5IZ7az6AMo.html
    VSite_Ku6, //酷6             示例：http://v.ku6.com/show/yuQq31tWTvFJeZtHjNBtWw...html
    VSite_Umiwi, //优米网		  示例：http://chuangye.umiwi.com/2010/0818/9534.shtml
    VSite_17173, // 17173 示例：http://17173.tv.sohu.com/v_102_601/MTIyMzAxNTM.html?vid=vyc
    VSite_QQ, //腾讯		      示例：http://v.qq.com/cover/o/o2v24no985ntwdo.html
    VSite_Qiyi, //奇艺            示例：http://www.qiyi.com/dianshiju/20110418/48af82e3012faac7.html
    VSite_Cntv, // cctv		      示例：http://news.cntv.cn/program/xwlb/20121130/107176.shtml
    VSite_56, // 56		      示例：http://www.56.com/u82/v_NTI2OTAyNDc.html
    VSite_M1905, // m1905电影网     示例：http://www.m1905.com/vod/play/520645.shtml
    VSite_6CN, //六间房		  示例：http://v.6.cn/video/16064185.html
    VSite_Joy, //激动网		  示例：http://v.joy.cn/movie/detail/70005107.htm
    VSite_163, //网易视频(163)   示例：http://v.163.com/zongyi/V86DILTF7/V95A26L93.html
    VSite_iFeng, //凤凰视频
    //示例：http://v.ifeng.com/ent/zongyi/201208/04938aa9-15fd-4328-bb7e-4d18a39eb1ce.shtml
    VSite_LeTv, //乐视网		  示例：http://www.letv.com/ptv/pplay/75143.html
    VSite_Funshion, //风行网          示例：http://www.funshion.com/vplay/m-113655.e-47/
    VSite_Wasu, //华数            示例：http://www.wasu.cn/Play/show/id/2643747
    VSite_PPTV, // PPTV            示例：http://v.pptv.com/show/X8OtK5P5aacKiaPA.html
    VSite_PPS, // PPS             示例：http://v.pps.tv/play_3DFFFD.html
    VSite_baomihua, //爆米花          示例：http://video.baomihua.com/in/url54773117/32030923
    VSite_sohu, //搜狐		      示例：http://tv.sohu.com/20130813/n384032686.shtml
    VSite_TangDou, //糖豆网          示例：http://www.tangdou.com/html/playlist/7403/5162993.html
    VSite_V1, //第一视频        示例：http://www.v1.cn/2014-04-10/1073024.shtml
    VSite_Novamov, // Novamov(国外视频，需要能正常访问播放）
    // 示例:http://www.novamov.com/mobile/video.php?id=58b46f0f0ec5b
    VSite_Allmyvideos, // VSite_Allmyvideos(国外视频，需要能正常访问播放）
    // 示例：http://allmyvideos.net/embed-cud2tadm41m4.html
    VSite_Videomega, // VSite_Videomega(国外视频，需要能正常访问播放）                示例:
    // http://videomega.tv/iframe.php?ref=RIAQQEFIZU&amp;width=1070&amp;height=600
    VSite_61, //淘米视频        示例：http://61.iqiyi.com/comic-play/8431/28.shtml
    VSite_Beva, //贝瓦网          示例：http://v.beva.com/player--id2092.html
    VSite_Vmovier, // V电影           示例：http://www.vmovier.com/45371?from=index_new
    VSite_Vimeo, // Vimeo(国外视频，需要能正常访问播放） 示例：http://www.vmovier.com/43958
    VSite_BlipTv, // BlipTv(国外视频，需要能正常访问播放）
    VSite_CbsNews, // CBS视频(国外视频，需要能正常访问播放）
    VSite_Acfun, // AcFun弹幕影视   示例：http://www.acfun.tv/v/ac1485766
    VSite_BiliBili, //哔哩哔哩弹幕影视 示例：http://www.bilibili.com/video/av1637699/
    VSite_YinyueTai, // 音悦台          示例：http://v.yinyuetai.com/video/2113124
    VSite_Xiami, // 虾米音乐        示例：http://www.xiami.com/song/1773431302
    VSite_Douban, // 豆瓣网          示例：http://movie.douban.com/trailer/164924/
    // http://music.douban.com/subject/26067993/
    VSite_Mtime, // 时光网          示例：http://video.mtime.com/50987/?mid=174144
    VSite_Kugou, // 酷狗音乐        示例：单曲：http://5sing.kugou.com/fc/13325572.html
    // 专辑：http://www.kugou.com/yy/album/single/541696.html
    // MV：http://www.kugou.com/mvweb/html/mv_93004.html
    VSite_Kuwo, // 酷我音乐        示例：http://www.kuwo.cn/mv/75934/
    // http://www.kuwo.cn/yinyue/3298907/
    VSite_KanKan, // 迅雷看看        示例：http://vod.kankan.com/v/71/71766/359006.shtml
    VSite_Taobao, // 淘宝视频
    // 示例：http://www.alibado.com/learning/study/detail-15378.htm?spm=a1z14.3053525.1996420561.6.Ome37o

    VSite_Mp4Star,
    VSite_Dailymotion,
    VSite_Hunantv,
    VSite_Xmovies8, // http://xmovies8.co/movie/vampire-diaries-season-5-2013/?part_id=1877#watch-movie
    VSite_Vodlocker, // http://vodlocker.com/embed-2ny5sy15by92-640x360.html
    VSite_VideoTT,
    VSite_OneDrive,
    VSite_TheFileMe,
    VSite_TheVideoMe,
    VSite_TheVideosTV,
    VSite_JustMP4,
    VSite_GoogleDocs,

    VSite_Hupu,
    VSite_Sinovision,
    VSite_XinHuaNet,
    VSite_Cloudzilla, // http://cloudzilla.to/embed/C5FYRDCQWDII0OIVOIFR25MRE
    VSite_Letwatch, // http://letwatch.us/embed-9phtq799wmjs-1070x600.html
    VSite_PutLocker, // http://www.putlocker.ms/watch-the-duff-online-free-2015-putlocker-v1.html

    VSite_Filmon,
    VSite_Break,
    VSite_LOL5s,
};

// 返回解析的结果，包括所有类型的视频格式（比如标清、高清、超清等），每种视频格式下又可能有多段（或者一段，但有两个备用地址，用fileNO来区分，请参考VideoSeg中fileNO的说明）
typedef struct
{
    enum VideoSiteID siteID; // 该网站的ID
    UINT64 timeLength; //视频总时长
    UINT64 frameCount; //帧数
    UINT64 totalSize; //总大小

    char *vName; //视频名字
    char *tags; //标签

    //视频可能有多种格式，每种视频的下载信息
    int streamCount; // 视频种类的个数
    VideoInType *streams; // 返回种类的数组，数组中的每个元素代表一种类型的视频（比如高清），里面其实还可能会有多段。

    //视频还可能会有相关地址 - 比如粤语版的网址，如果有其它相关性地址，这里也会列出
    int relatedUrlCount;
    RelatedWebUrl *relatedUrls;

} VideoResult;
#pragma pack(pop, old_value)


/// ==================================================================
///
///  以下是对外提供的接口，调用DLVideo_Parse后，需要调用DLVideo_FreeVideoResult
///  释放DLL内部分配的内存
///
/// ==================================================================

#pragma pack(push, old_value) // 保存VC++编译器结构对齐字节数
#pragma pack(4) // 设置为以一字节对齐。
typedef struct
{
    bool bUseIEProxy; // 是否使用IE默认的proxy，如果是，则后面的3项代理的设置无用
    const char *proxyUrl; // 代理的地址
    const char *pstrProxyName; // 代理的用户名
    const char *pstrProxyBypass; // 代理密码
} ProxySetInfo;

#pragma pack(pop, old_value)

#pragma pack(push, old_value) // 保存VC++编译器结构对齐字节数
#pragma pack(4)
typedef struct
{
    int hd; // 预留暂未启用  清晰度：0：全部,
    // 1=>低清，2=>标清，3=>高清，4=>超清，5=>720P，6=>1080P，7=>高码1080P，8=>原画，9=>4K。如果所选清晰度没有视频会降到低一清晰度
    int seg; // 预留暂未启用（只部分网站有支持） 分段的设置，是否只要不分段的视频。
    // 0：默认是分段、不分段一起返回； 1：只要不分段的单段视频；
    // 2：如果找不到手机版不分段的视频，则再返回分段的。  3：只要多段，不要手机版
    int m3u8; // 预留暂未启用（只部分网站有支持） 如果是选择单段视频，是否只需要m3u8格式的结果。
    // 0：默认，不只返回m3u8；  1：只返回m3u8  2：只返回其它
    DWORD dwTimeout; //解析中一般会有多次http请求，这里是设置http请求的超时时间，单位为毫秒，如果为0，则使用默认值，也就是120000ms。
    const char *clientIP; //解析者的IP地址，字符串形式，如果为NULL或者""，则直接使用解析组件所在机器的IP。不是所有网站都支持这种模拟的CDN解析，但大部分网站支持
    const char *userAgent; // 土豆网等特殊网页，需要使用相同的userAgent（解析者和下载者）。默认使用的IE
    // 的userAgent

} AdvParseSetting;
#pragma pack(pop, old_value)


//==================================================
// 真正的解析函数入口
//==================================================
// 解析一个网址，返回视频真正的地址信息
DLVideo_API HRESULT WINAPI DLVideo_Parse (const char *webUrl, // 视频所在页面的地址
                                          VideoResult **pInfo, // 传出视频的真实信息，这块地址随后需要进行释放。
                                          ProxySetInfo *proxyInfo, // 代理设置
                                          AdvParseSetting *advSetting // 解析本网址的高级设置，详见AdvParseSetting结构体的定义，如果传入NULL，则使用默认设置
                                          );

// 释放传出的一块内存，防止内存泄露
DLVideo_API void WINAPI DLVideo_FreeVideoResult (VideoResult *pInfo);

// 全局设置
DLVideo_API HRESULT WINAPI DLVideo_SetConfig (const char *configInfo);

// IOS等平台下的序列号机制
#ifndef WIN32
DLVideo_API int DLVideoParser_Init (const char *pKey1, const char *pKey2);

#else // Win32下的序列号机制
// 设置正版序列号
DLVideo_API void WINAPI DLVideo_SetAppSettings (ULONGLONG cert1,
                                                LPCSTR productNumber,
                                                ULONGLONG cert2,
                                                ULONGLONG cert3,
                                                ULONGLONG cert4);
// 获取机器码
DLVideo_API LPCSTR WINAPI DLVideo_GetMachineCode ();
#endif


//==================================================
// 以下是一些清晰度的定义
//==================================================

//// 定义视频清晰度
// namespace VideoClear
//{
////
///以下是视频清晰度的一些名称，因为不同网站的叫法不同，因此这里只有相对的参考意义，并不绝对可比。比如，A网站的标清可能比另一个网站的超清都清晰也是有可能的。
////
///某个网站叫原画，但原画是否一定比720P清晰，这个不一定。因为不同网站没有可比性，甚至同一个网站不同时期叫法也不同，只是大致的比较
//
////
///如果是手机版(Mobile）或者直播(Live)也会后面跟上清晰度的，所以清晰度这些字符，基本可以确定是一定会有的。
//
//// 大部分网站会有 Speed SD HD SuperHD等名称，少数会有720P -->4K这些
//
// static const std::string SPEED = "Speed"; //极速
// static const std::string SD = "SD"; //标清
// static const std::string HD = "HD"; //高清
// static const std::string SuperHD = "SuperHD"; //超清
// static const std::string P720 = "720P"; // 720P
// static const std::string Orignal = "Orignal"; //原画  乐视和土豆会有
// static const std::string P1080 = "1080P"; // 1080P
// static const std::string K2 = "2K"; // 2K    目前可能youtube遇到
// static const std::string K4 = "4K"; // 4K    目前可能乐视、youtube遇到
//};
//
////
///以下是一些辅助参考信息，不一定有，只是在我们确定视频符合这些特征时才会出现，比如我们判断视频是FLV，就会标记下他有FLV属性。或者发现视频是一个直播地址，标记LIVE
////
///或者发现视频是ipad版本，会标记为Mobile等。但不标记的，只是说明我们没有判断出来，也不一定付是FLV文件。不是所有网站都有以下信息。
//// 以下信息后面也会跟上清晰度的，比如 FLV-SD MP-HD  Mobile-m3u8-SD
//// 这种。总之，SD/HD之类的清晰度是一定会有的
// namespace VideoType
//{
//// 标记是手机版，如果手机版也有多种，有可能会有 Mobile-SD这种字样出现
// static const std::string Mobile = "Mobile";
//
//// 直播类型的地址（只有CCTV有可能有rtmp的直播地址、56.com目前做了直播房间的分析）
// static const std::string Live = "Live";
//
////
///部分网站同一清晰度还可能有不同格式，比如youtube格式比较多，上面清晰度不足以识别，还会有以下字符扩展，用-间隔，示例：有可能会有
//// m3u8-SD、FLV-SD这种字样出现
///*
//"FLV" "3GP" "MP4" "WebM" "3D.MP4" "3D.WebM"
//*/
// static const std::string FLV = "FLV";
// static const std::string GP3 = "3GP";
// static const std::string MP4 = "MP4";
// static const std::string WebM = "WebM";
// static const std::string MOV = "MOV";
// static const std::string M3U8 = "m3u8";
// static const std::string MP4_3D = "3D.MP4";
// static const std::string WebM_3D = "3D.WebM";
//
////虾米网是MP3的音乐
// static const std::string MP3 = "MP3";
////酷我音乐等有aac格式的
// static const std::string AAC = "AAC";
//}


/*

==================================================
视频地址解析组件的其它使用的注意事项：
==================================================

1) 视频地址的有效期注意事项：
很多视频网站上解析出来的视频地址，只在一段时间内有效，这个应该占一半以上，比如对A视频，解析出来了一些地址，这些地址在半个小时内去使用是没问题的。但超过后，地址就失效了。
另外，如果你已经在播放或者下载了（跟这个地址建立好连接了），则不受这个限制，这个限制是在建立连接时判断。

因此，建议，每次视频地址在使用（播放）前进行解析，解析后立即使用，不要间隔太久。

2）土豆网的视频有user-agent的限制。
土豆网的视频要求：解析软件询问他们服务器视频地址时用的user-agent要和播放（下载）软件用的user-agent一致。因此，我们建议对所有的视频网站（或者只对土豆），可以传入一个user-agent，让内部解析使用贵方指定的user-agent。然后贵方的下载（播放）软件也用相同的user-agent

3）m1905的视频有refer的限制
m1905的视频一般会返回2个地址，一个是flv.开头的域名，一个是flv2.开头的域名。
这2个域名是不同的服务器，其中一组服务器是限制refer的。
因此为了安全，最好下载（播放）时，播放器的refer指定为这个视频网页地址。

4）视频的序号：
如果解析出来有多段视频地址（数目大于1），这里面需要注意一个segNO的问题。有些视频网站，比如m1905和风行网，他们实际是单段的视频，但服务器会同时给出1-2个备用地址，意思是：让客户端如果A地址下载不到，可以切换到B地址，这种其实并不是先播放完第一段再去播放第二段（他们是完全相同的一段视频）。这种情况下，segNO就都是0。
如果你检测到了多段地址，但segNO都是0，那么他们就不是多段视频。

多段视频的序号是0、1、2这样排列的，单段视频的备用地址是0、0、0这样排列的。如果是备用地址，则序号会有重复，比如0、0（两个0的序号），或者两个1的序号，代表这个段落的地址是备用地址。

5）是选择网站端解析，还是客户端解析
网站端解析的优点是：如果有网站改版，很容易调整和升级；缺点是服务器压力大，并且，很多网站返回的地址是CDN的地址，网站服务器去解析，返回的是距离服务器速度最快的地址，不一定客户端下载很快。
客户端解析：优点是很少的服务器压力，只需要服务器提供下网页地址，或者少量交互；而且解析出来的视频距离自己是速度最快的。缺点是如果网站有改版，需要升级。但在android等移动终端，很多软件的升级频率是大于网站改版次数的，一般平均最多2-3个月一次升级就够了。甚至有时候一年升级1-2次就够。

6）淘宝网站的视频地址下载说明：
淘宝上的视频只有第一段是有关键帧的，以后每段其实只是二进制，并没有合法的FLV视频头。其实可以理解为服务器他们本身存的就是一个单段的，但做了一些特殊防盗链，必须分批次下载。针对这类视频，只需要下载后的视频进行二进制合并即可。比如用批处理命令copy
/B 1.flv+2.flv+3.flv....  all.flv

7）迅雷看看的视频地址的下载说明：
迅雷看看上面的视频和淘宝的做法类似，但他们对分段要求更小，所以会显示很多段。而且要求这类地址在下载时，必须在header里面传入正确的range:
(具体如何下载，正式客户我们会提供技术支持说明）


*/


#endif