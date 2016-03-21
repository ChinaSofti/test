//
//  SVHeaderView.m
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVHeaderView.h"

@implementation SVHeaderView

//初始化方法
- (instancetype)init
{
    if ([super init])
    {
        NSString *title1 = I18N (@"Initial Buffer Time");
        NSString *title2 = I18N (@"Stalling Times");
        // HeaderView中的初始化

        // videotesting
        //设置Label
        _uvMosBarView = [[UIView alloc]
        initWithFrame:CGRectMake (FITWIDTH (35), FITWIDTH (100), FITWIDTH (60), FITWIDTH (20))];

        _speedLabel =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_uvMosBarView.rightX + FITWIDTH (33),
                                                        FITWIDTH (100), FITWIDTH (40), FITWIDTH (20))
                                   withFont:19
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"0"];
        _speedLabel1 =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_uvMosBarView.rightX + FITWIDTH (43),
                                                        FITWIDTH (101), FITWIDTH (80), FITWIDTH (20))
                                   withFont:10
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"ms"];


        _bufferLabel =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_speedLabel.rightX + FITWIDTH (65),
                                                        FITWIDTH (100), FITWIDTH (50), FITWIDTH (20))
                                   withFont:19
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"0"];

        _uvMosNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (35), _uvMosBarView.bottomY + FITWIDTH (10),
                                         FITWIDTH (45), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:@"U-vMOS"];

        _speedNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_uvMosNumLabel.rightX + FITWIDTH (20),
                                         _uvMosBarView.bottomY + FITWIDTH (10), FITWIDTH (100), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title1];

        _bufferNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_speedNumLabel.rightX + FITWIDTH (10),
                                         _uvMosBarView.bottomY + FITWIDTH (10), FITWIDTH (80), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title2];
        //所有Label居中对齐

        _bufferLabel.textAlignment = NSTextAlignmentCenter;
        _speedLabel.textAlignment = NSTextAlignmentRight;
        _speedLabel1.textAlignment = NSTextAlignmentCenter;
        _uvMosNumLabel.textAlignment = NSTextAlignmentCenter;
        _speedNumLabel.textAlignment = NSTextAlignmentCenter;
        _bufferNumLabel.textAlignment = NSTextAlignmentCenter;


        // webtesting
        NSString *title3 = I18N (@"Response Time");
        NSString *title4 = I18N (@"Download Speed");
        NSString *title5 = I18N (@"Load duration");
        //设置Label
        _ResponseLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (25), FITWIDTH (100), FITWIDTH (60), FITWIDTH (20))
                    withFont:16
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"N/A"];
        _ResponseLabel1 =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_ResponseLabel.rightX - FITHEIGHT (5),
                                                        FITWIDTH (101), FITWIDTH (20), FITWIDTH (20))
                                   withFont:10
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"s"];
        _DownloadLabel =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_ResponseLabel.rightX + FITWIDTH (23),
                                                        FITWIDTH (100), FITWIDTH (70), FITWIDTH (20))
                                   withFont:16
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"N/A"];
        _DownloadLabel1 =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_ResponseLabel.rightX + FITWIDTH (95),
                                                        FITWIDTH (101), FITWIDTH (30), FITWIDTH (20))
                                   withFont:10
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"kbps"];

        _LoadLabel =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_DownloadLabel.rightX + FITWIDTH (5),
                                                        FITWIDTH (100), FITWIDTH (70), FITWIDTH (20))
                                   withFont:16
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"N/A"];
        _LoadLabel1 =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_ResponseLabel.rightX + FITWIDTH (163),
                                                        FITWIDTH (101), FITWIDTH (20), FITWIDTH (20))
                                   withFont:10
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"s"];

        _ResponseNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (35), _ResponseLabel.bottomY + FITWIDTH (10),
                                         FITWIDTH (100), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title3];

        _DownloadNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_ResponseNumLabel.rightX, _ResponseLabel.bottomY + FITWIDTH (10),
                                         FITWIDTH (90), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title4];

        _LoadNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_DownloadNumLabel.rightX, _ResponseLabel.bottomY + FITWIDTH (10),
                                         FITWIDTH (80), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title5];
        //所有Label居中对齐
        _ResponseLabel.textAlignment = NSTextAlignmentRight;
        _ResponseLabel1.textAlignment = NSTextAlignmentCenter;
        _DownloadLabel.textAlignment = NSTextAlignmentRight;
        _DownloadLabel1.textAlignment = NSTextAlignmentCenter;
        _LoadLabel.textAlignment = NSTextAlignmentRight;
        _LoadLabel1.textAlignment = NSTextAlignmentCenter;

        _ResponseNumLabel.textAlignment = NSTextAlignmentCenter;
        _DownloadNumLabel.textAlignment = NSTextAlignmentCenter;
        _LoadNumLabel.textAlignment = NSTextAlignmentCenter;

        // speedtesting
        NSString *title6 = I18N (@"Delay");
        NSString *title7 = I18N (@"Download Speed");
        NSString *title8 = I18N (@"Upload speed");
        //设置Label
        _Delay = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (25), FITWIDTH (100), FITWIDTH (60), FITWIDTH (20))
                    withFont:16
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"N/A"];
        _Delay1 = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_Delay.rightX, FITWIDTH (101), FITWIDTH (20), FITWIDTH (20))
                    withFont:10
              withTitleColor:RGBACOLOR (250, 180, 86, 1)
                   withTitle:@"ms"];
        _Downloadspeed =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_Delay.rightX + FITWIDTH (13),
                                                        FITWIDTH (100), FITWIDTH (70), FITWIDTH (20))
                                   withFont:16
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"N/A"];
        _Downloadspeed1 =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_Delay.rightX + FITWIDTH (83),
                                                        FITWIDTH (101), FITWIDTH (30), FITWIDTH (20))
                                   withFont:10
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"Mbps"];

        _Uploadspeed =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_Downloadspeed.rightX + FITWIDTH (10),
                                                        FITWIDTH (100), FITWIDTH (70), FITWIDTH (20))
                                   withFont:16
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"N/A"];
        _Uploadspeed1 =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_Delay.rightX + FITWIDTH (163),
                                                        FITWIDTH (101), FITWIDTH (30), FITWIDTH (20))
                                   withFont:10
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"Mbps"];

        _DelayNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (35), _Delay.bottomY + FITWIDTH (10), FITWIDTH (70), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title6];

        _DownloadspeedNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_DelayNumLabel.rightX, _Delay.bottomY + FITWIDTH (10),
                                         FITWIDTH (90), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title7];

        _UploadspeedNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_DownloadspeedNumLabel.rightX,
                                         _Delay.bottomY + FITWIDTH (10), FITWIDTH (80), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:title8];
        //所有Label居中对齐
        _Delay.textAlignment = NSTextAlignmentRight;
        _Delay1.textAlignment = NSTextAlignmentCenter;
        _Downloadspeed.textAlignment = NSTextAlignmentRight;
        _Downloadspeed1.textAlignment = NSTextAlignmentCenter;
        _Uploadspeed.textAlignment = NSTextAlignmentRight;
        _Uploadspeed1.textAlignment = NSTextAlignmentCenter;

        _DelayNumLabel.textAlignment = NSTextAlignmentCenter;
        _DownloadspeedNumLabel.textAlignment = NSTextAlignmentCenter;
        _UploadspeedNumLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}
@end
