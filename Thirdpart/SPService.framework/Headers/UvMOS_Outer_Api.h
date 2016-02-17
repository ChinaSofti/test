#ifndef _UVMOS_OUTER_API_H_
#define _UVMOS_OUTER_API_H_

#ifdef __cplusplus
extern "C" {
#endif

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
 * 视频/屏幕分辨率枚举值，暂不支持非标准分辨率
 */
typedef enum _UvMOSVideoResolution {
    RESOLUTION_360P = 0, // 分辨率360P, 480*360
    RESOLUTION_480P = 1, // 分辨率480P, 640*480
    RESOLUTION_720P = 2, // 分辨率720P, 1280*720
    RESOLUTION_1080P = 3, // 分辨率720P, 1920*1080
    RESOLUTION_2K = 4, // 分辨率2K, 2560×1440
    RESOLUTION_4K = 5, // 分辨率4K, 3840×2160
    RESOLUTION_UNKNOW = 6 // 分辨率无法获取，视频分辨率无法获取时，将无法进行UvMOS计算，屏幕分辨率无法获取时，将忽略其影响
} UvMOSVideoResolution;

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

/**
 * UvMOS错误码
 */
#ifndef _UVMOS_OUTER_API_ERROR_CODE_
#define _UVMOS_OUTER_API_ERROR_CODE_
typedef enum _UvMOSErrorCode {
    SUCCESS = 0,
    INVAILD_PARAMS = -1,
    OUT_OF_MEMORY = -2,
    UVMOS_ENGINE_FAILED = -3,
    INVAILD_SERVICE_ID = -4,
    ANALYSIS_DATA_FAILED = -5
} UvMOSErrorCode;
#endif

/**
 * 媒体基础信息
 */
typedef struct _UvMOSMediaInfo
{
    UvMOSContentProvider eContentProvider; // 内容提供商，取值详见枚举类型UvMOSContentProvider

    UvMOSVideoResolution eVideoResolution; // 视频分辩率，取值详见枚举类型UvMOSVideoResolution
    // --需要考虑分辨率自适应
    unsigned int iFrameRate; // 视频帧率
    unsigned int iAvgBitrate; // 媒体文件平均码率，单位kbps --媒体文件整体码率
    UvMOSVideoCodec eVideoCodec; // 视频编码格式，取值详见枚举类型UvMOSVideoCodec

    float fScreenSize; // 屏幕尺寸，单位英寸，输入为0时，屏幕映射默认为42寸TV
    UvMOSVideoResolution eScreenResolution; // 屏幕分辩率，取值详见枚举类型UvMOSVideoResolution
} UvMOSMediaInfo;

/**
 * VOD采样周期信息
 */
typedef struct _UvMOSVODPeriodInfo
{
    unsigned int iPeriodLength; // 采样周期时长，单位秒(s)，建议按照观看时间反馈，近似可以按照内容的实际时间反馈

    unsigned int iInitBufferLatency; // 初始缓冲时长，单位毫秒(ms)，采样周期内初始缓冲事件未完成，或采样周期内没有初始缓冲事件时，输入为0

    unsigned int iAvgVideoBitrate; // 支持VBR特性时，采样周期内视频文件平均码率，单位kbps，无法获得时，输入为0
    unsigned int iAvgKeyFrameSize; // 支持VBR特性时，采样周期内I帧平均大小，单位字节，无法获得时，输入为0

    unsigned int iStallingFrequency; // 采样周期内，卡顿次数
    unsigned int iStallingDuration; // 采样周期内，平均卡顿时长，单位毫秒(ms)
    unsigned int iStallingInterval; // 采样周期内，平均卡顿间隔，单位毫秒(ms)
} UvMOSVODPeriodInfo;

/**
 * UvMOS计算结果
 */
typedef struct _UvMOSResult
{
    double sQualityPeriod; // 视频质量周期分数（1－5）
    double sInteractionPeriod; // 交互体验周期分数（1－5）
    double sViewPeriod; // 观看体验周期分数（1－5）
    double uvmosPeriod; // 视频播放周期UvMOS得分（1－5）

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
int registerUvMOSService (UvMOSMediaInfo *pMediaInfo);

/**
 * DLL导出方法，根据指定的服务ID，注销UvMOS服务
 *
 * @Param iServiceId 输入参数，服务ID
 *
 * @Return 成功返回0，失败返回 -1
 */
int unregisterUvMOSService (int iServiceId);

/**
 * DLL导出方法，根据服务ID和VOD采样信息，计算UvMOS得分
 *
 * @Param iServiceId 输入参数，服务ID
 * @Param pVODPeriodInfo 输入参数，VOD采样信息
 * @Param pUvMOSResult 输出参数，返回UvMOS计算结果
 *
 * @Return 成功返回0，失败返回-1
 */
int calculateUvMOSVODPeriod (int iServiceId, UvMOSVODPeriodInfo *pVODPeriodInfo, UvMOSResult *pUvMOSResult);

#ifdef __cplusplus
}
#endif
#endif