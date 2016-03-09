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
        NSString *title1 = I18N (@"Initial buffer time");
        NSString *title2 = I18N (@"Butter times");
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
                                         FITWIDTH (60), FITWIDTH (10))
                    withFont:13
              withTitleColor:RGBACOLOR (81, 81, 81, 1)
                   withTitle:@"U-vMOS"];

        _speedNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (_uvMosNumLabel.rightX + FITWIDTH (20),
                                         _uvMosBarView.bottomY + FITWIDTH (10), FITWIDTH (90), FITWIDTH (10))
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
        NSString *title4 = I18N (@"Download");
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
                                                        FITWIDTH (101), FITWIDTH (20), FITWIDTH (20))
                                   withFont:10
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"kpps"];

        _LoadLabel =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_DownloadLabel.rightX + FITWIDTH (15),
                                                        FITWIDTH (100), FITWIDTH (70), FITWIDTH (20))
                                   withFont:16
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"N/A"];
        _LoadLabel1 =
        [CTWBViewTools createLabelWithFrame:CGRectMake (_ResponseLabel.rightX + FITWIDTH (173),
                                                        FITWIDTH (101), FITWIDTH (20), FITWIDTH (20))
                                   withFont:10
                             withTitleColor:RGBACOLOR (250, 180, 86, 1)
                                  withTitle:@"s"];

        _ResponseNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (35), _ResponseLabel.bottomY + FITWIDTH (10),
                                         FITWIDTH (80), FITWIDTH (10))
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
    }
    return self;
}
@end
