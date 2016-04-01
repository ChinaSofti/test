#ifndef _UVMOS_OUTER_API_H_
#define _UVMOS_OUTER_API_H_

#ifdef __cplusplus
extern "C" {
#endif


typedef enum _UvMOSMediaType {
    // 点播类型
    MEDIA_TYPE_VOD = 0,
    // 直播类型
    MEDIA_TYPE_LIVE = 1
} UvMOSMediaType;

/**
 * 内容提供商枚举值，无法确定时默认为FFMPEG
 */
typedef enum _UvMOSContentProvider {
    CONTENT_PROVIDER_FFMPEG = 0, // 视频内容采用开源ffmpeg编码
    CONTENT_PROVIDER_HUAWEI = 1, // 视频内容采用HW自研编码器
    CONTENT_PROVIDER_YOUTUBE = 2, // 视频内容来自YOUTUBE
    CONTENT_PROVIDER_YOUKU = 3, // 视频内容来自优酷
    CONTENT_PROVIDER_TENCENT = 4, // 视频内容来自腾讯
    CONTENT_PROVIDER_SOHU = 5, // 视频内容来自搜狐
    CONTENT_PROVIDER_IQIY = 6, // 视频内容来自爱奇艺
    CONTENT_PROVIDER_YOUPENG = 7, // 视频内容来自优朋
    CONTENT_PROVIDER_OTHER = 8 // 视频内容来自其他内容提供商
} UvMOSContentProvider;

/**
 * 视频编码格式枚举值，无法确定时默认为H264
 */
typedef enum _UvMOSVideoCodec {
    VIDEO_CODEC_H264 = 0, // 视频编码格式H264
    VIDEO_CODEC_H265 = 1, // 视频编码格式H265/HEVC，当前版本只支持分辨率720P及以上
    VIDEO_CODEC_VP9 = 2, // 视频编码格式VP9
    VIDEO_CODEC_H263 = 3, // 视频编码格式H263，当前版本暂时不支持
    VIDEO_CODEC_MP4 = 4, // 视频编码格式MP4，当前版本暂时不支持
    VIDEO_CODEC_OTHER = 5 // 其他视频编码格式，当前版本暂时不支持
} UvMOSVideoCodec;

typedef enum _UvMOSPlayStatus {
    // 画面正常
    STATUS_PLAYING = 0,
    // 视频正在进行初始化缓冲
    STATUS_INIT_BUFFERING = 1,
    // 视频初始化缓冲结束
    STATUS_BUFFERING_END = 2,
    // 视频画面开始出现损伤
    STATUS_IMPAIR_START = 3,
    // 视频画面持续损伤中
    STATUS_IMPAIRING = 4,
    // 视频画面损伤结束，恢复正常
    STATUS_IMPAIR_END = 5
} UvMOSPlayStatus;

/**
 * UvMOS错误码
 */
typedef enum _UvMOSReturnCode {
    SUCCESS = 0,
    INVAILD_PARAMS = -1,
    OUT_OF_MEMORY = -2,
    UVMOS_ENGINE_FAILED = -3,
    INVAILD_SERVICE_ID = -4,
    ANALYSIS_DATA_FAILED = -5
} UvMOSReturnCode;


/**
 * 媒体基础信息
 */
typedef struct _UvMOSMediaInfo
{
    UvMOSMediaType eMediaType;
    UvMOSContentProvider eContentProvider; // 内容提供商，取值详见枚举类型UvMOSContentProvider
    unsigned int iVideoResolutionWidth; // 视频宽度
    unsigned int iVideoResolutionHeigth; // 视频高度
    UvMOSVideoCodec eVideoCodec; // 视频编码格式，取值详见枚举类型UvMOSVideoCodec
    double dScreenSize; // 屏幕尺寸，单位英寸，输入为0时，屏幕映射默认为42寸TV
    unsigned int iScreenResolutionWidth; // 屏幕分辨率宽度
    unsigned int iScreenResolutionHeight; // 屏幕分辨率高度

} UvMOSMediaInfo;

/**
 * VOD采样周期信息
 */
typedef struct _UvMOSSegementInfo
{
    //    unsigned int iPeriodLength; //
    //    采样周期时长，单位秒(s)，建议按照观看时间反馈，近似可以按照内容的实际时间反馈
    //
    //    unsigned int iInitBufferLatency; //
    //    初始缓冲时长，单位毫秒(ms)，采样周期内初始缓冲事件未完成，或采样周期内没有初始缓冲事件时，输入为0
    //
    //    unsigned int iAvgVideoBitrate; //
    //    支持VBR特性时，采样周期内视频文件平均码率，单位kbps，无法获得时，输入为0
    //    unsigned int iAvgKeyFrameSize; //
    //    支持VBR特性时，采样周期内I帧平均大小，单位字节，无法获得时，输入为0
    //
    //    unsigned int iStallingFrequency; // 采样周期内，卡顿次数
    //    unsigned int iStallingDuration; // 采样周期内，平均卡顿时长，单位毫秒(ms)
    //    unsigned int iStallingInterval; // 采样周期内，平均卡顿间隔，单位毫秒(ms)
    unsigned int iTimeStamp; // 视频片段截止时间戳，已视频开始加载时为开始时间点，单位毫秒
    UvMOSPlayStatus ePlayStatus; // 当前时间点视频播放状态
    double dVideoFrameRate; // 视频帧率，采用VFR时，输入视频片段内平均帧率
    unsigned int iAvgVideoBitrate; // 视频平均码率，单位Kbps， 采用VBR时，输入视频片段内平均码率
    unsigned int iAvgKeyFrameSize; // 采用VBR时，输入视频片段内I帧平均大小，单位子节（Byte），否则输入为0
    unsigned int iImpairmentDegree; // 画面花屏奇迹，平均花屏面积百分比（％），卡顿时为100%，卡顿时间为100%，花屏时为［1%，
    // 100%］，其他情况为0%

} UvMOSSegmentInfo;

typedef struct _UvMOSStatisticsInfo
{
    unsigned int iVideoPlayDuration; // 视频可播放时长，单位秒（s）,不包含初始化缓冲时间和画面卡顿时间
    unsigned int iInitBufferLatency; // 初始化缓冲时长，单位毫秒（ms），包括初始加载（点播），频道切换（直播）
    double dVideoFrameRate; // 视频帧率，采用VFR时，输入视频片段内平均帧率
    unsigned int iAvgVideoBitrate; // 视频平均码率，单位Kbps，采用VBR时，输入视频片段内平均码率
    unsigned int iAvgKeyFrameSize; // 采用VBR时，输入视频片段内I帧平均大小，单位子节（Byte），否则输入为0
    unsigned int iImpairmentFrequency; // 视频播放期间，画面损伤次数，包括卡顿，花屏
    unsigned int iImpairmentDuration; // 视频播放期间，画面损伤总时长，单位毫秒（ms）
    unsigned int iImpairmentDegree; // 画面花屏奇迹，平均花屏面积百分比（％），卡顿时为100%，卡顿时间为100%，花屏时为［1%，
    // 100%］，其他情况为0%
} UvMOSStatisticsInfo;

/**
 * UvMOS计算结果
 */
typedef struct _UvMOSResult
{
    double sQualityInstant; // 视频质量周期分数（1－5）
    double sInteractionInstant; // 交互体验周期分数（1－5）
    double sViewInstant; // 观看体验周期分数（1－5）
    double uvmosInstant; // 视频播放周期UvMOS得分（1－5）

    double sQualitySession; // 视频质量会话分数（1－5）
    double sInteractionSession; // 交互体验会话分数（1－5）
    double sViewSession; // 观看体验会话分数（1－5）
    double uvmosSession; // 视频从开始播放到现在的UvMOS得分（1－5）
} UvMOSResult;

/**
 * DLL导出方法，注册UvMOS服务
 *
 * @Parameters 输入参数，pMediaInfo 媒体信息
 *
 * @Return 成功返回服务ID，失败返回 -1
 */
#ifdef _WIN32
__declspec(dllexport) int __stdcall registerUvMOSService (UvMOSMediaInfo *pMediaInfo, void **hServiceHandle);
#else
int registerUvMOSService (UvMOSMediaInfo *pMediaInfo, void **hServiceHandle);
#endif

#ifdef _WIN32
__declspec(dllexport) int __stdcall resetMediaInfo (void *hServiceHandle, UvMOSMediaInfo *pMediaInfo);
#else
int resetMediaInfo (void *hServiceHandle, UvMOSMediaInfo *pMediaInfo);
#endif


/**
 * DLL导出方法，根据指定的服务ID，注销UvMOS服务
 *
 * @Param iServiceId 输入参数，服务ID
 *
 * @Return 成功返回0，失败返回 -1
 */
#ifdef _WIN32
__declspec(dllexport) int __stdcall unregisterUvMOSService (void *hServiceHandle);
#else
int unregisterUvMOSService (void *hServiceHandle);
#endif


#ifdef _WIN32
__declspec(dllexport) int __stdcall calculateUvMOSSegment (void *hServiceHandle,
                                                           UvMOSSegmentInfo *pSegmentInfo,
                                                           UvMOSResult *pUvMOSResult);
#else

int calculateUvMOSSegment (void *hServiceHandle, UvMOSSegmentInfo *pSegmentInfo, UvMOSResult *pUvMOSResult);
#endif

#ifdef _WIN32
__declspec(dllexport) int __stdcall calculateUvMOSNetworkPlan (UvMOSMediaInfo *pMediaInfo,
                                                               UvMOSStatisticsInfo *pStatisticsInfo,
                                                               UvMOSResult *pUvMOSResult);
#else
int calculateUvMOSNetworkPlan (UvMOSMediaInfo *pMediaInfo, UvMOSStatisticsInfo *pStatisticsInfo, UvMOSResult *pUvMOSResult);
#endif

#ifdef _WIN32
__declspec(dllexport) char *__stdcall getSDKCurVersion ();
#else
char *getSDKCurVersion ();
#endif

#ifdef __cplusplus
}
#endif

#endif