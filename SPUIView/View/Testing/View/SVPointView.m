//
//  SVPointView.m
//  SPUIView
//
//  Created by WBapple on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//


#import "SVPointView.h"
#import "SVTestingCtrl.h"
#import <SPCommon/SVI18N.h>
#import <SPCommon/UUBar.h>

@interface SVPointView ()
//定义转盘imageView
@property (weak, nonatomic) IBOutlet UIImageView *imgViewWheel;

@end

@implementation SVPointView
//初始化方法
- (instancetype)init
{
    if ([super init])
    {
        NSString *title1 = I18N (@"Initial buffer time");
        NSString *title2 = I18N (@"Butter times");
        NSString *title3 = I18N (@"Video server location");
        NSString *title4 = I18N (@"Resolution");
        NSString *title5 = I18N (@"Bit rate");
        // 1.HeaderView中的初始化

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


        // 2.TestingView中的初始化
        _panelView = [[UIView alloc]
        initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (160), FITWIDTH (280), FITWIDTH (280))];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.size = CGSizeMake (280, 280);
        imageView.image = [UIImage imageNamed:@"clock_video_panel"];
        imageView.center = CGPointMake (_panelView.frame.size.width / 2, _panelView.frame.size.height / 2);
        [_panelView addSubview:imageView];

        _middleView = [[UIView alloc]
        initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (160), FITWIDTH (280), FITWIDTH (280))];
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView2.size = CGSizeMake (280, 280);
        imageView2.image = [UIImage imageNamed:@"clock_middle"];
        imageView2.center = CGPointMake (_panelView.frame.size.width / 2, _panelView.frame.size.height / 2);
        [_middleView addSubview:imageView2];


        _grayView = [[SVPointView alloc]
        initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (160), FITWIDTH (280), FITWIDTH (280))];
        UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView3.size = CGSizeMake (280, 280);
        imageView3.image = [UIImage imageNamed:@"clock_pointer_gray"];
        imageView3.center = CGPointMake (_panelView.frame.size.width / 2, _panelView.frame.size.height / 2);
        [_grayView addSubview:imageView3];


        _label1 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (130), FITWIDTH (290), FITWIDTH (60), FITWIDTH (20))];
        _label1.text = @"U-vMos";
        _label1.font = [UIFont systemFontOfSize:13.0f];
        _label1.textAlignment = NSTextAlignmentCenter;


        _label2 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (110), FITWIDTH (350), FITWIDTH (100), FITWIDTH (50))];
        _label2.text = @"0.00";
        _label2.textColor = RGBACOLOR (44, 166, 222, 1);
        _label2.font = [UIFont systemFontOfSize:36.0f];
        _label2.textAlignment = NSTextAlignmentCenter;


        _pointView = [[[NSBundle mainBundle] loadNibNamed:@"SVPointView" owner:nil options:nil] lastObject];
        _pointView.center = _panelView.center;
        //        _pointView.center = CGPointMake(_panelView.frame.size.width/2,
        //        _panelView.frame.size.height/2);

        // 3.videoView中的初始化


        // 4.FooterView中的初始化
        //设置Label
        _placeLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (170), FITWIDTH (425), FITWIDTH (150), FITWIDTH (20))
                    withFont:16
              withTitleColor:[UIColor blackColor]
                   withTitle:@""];

        _resolutionLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (230), FITWIDTH (470), FITWIDTH (80), FITWIDTH (20))
                    withFont:10
              withTitleColor:[UIColor blackColor]
                   withTitle:@""];

        _bitLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (230), FITWIDTH (495), FITWIDTH (80), FITWIDTH (20))
                    withFont:10
              withTitleColor:[UIColor blackColor]
                   withTitle:@""];

        _placeNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (170), FITWIDTH (445), FITWIDTH (150), FITWIDTH (20))
                    withFont:12
              withTitleColor:[UIColor lightGrayColor]
                   withTitle:title3];

        _resolutionNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (170), FITWIDTH (470), FITWIDTH (50), FITWIDTH (20))
                    withFont:10
              withTitleColor:[UIColor lightGrayColor]
                   withTitle:title4];

        _bitNumLabel = [CTWBViewTools
        createLabelWithFrame:CGRectMake (FITWIDTH (170), FITWIDTH (495), FITWIDTH (50), FITWIDTH (20))
                    withFont:10
              withTitleColor:[UIColor lightGrayColor]
                   withTitle:title5];
        //所有Label居中对齐
        _placeLabel.textAlignment = NSTextAlignmentLeft;
        _bitLabel.textAlignment = NSTextAlignmentRight;
        _resolutionLabel.textAlignment = NSTextAlignmentRight;
        _placeNumLabel.textAlignment = NSTextAlignmentLeft;
        _resolutionNumLabel.textAlignment = NSTextAlignmentLeft;
        _bitNumLabel.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}
//开始转动方法
- (void)start
{

    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector (rotate)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

//转动角度,速度控制
- (void)rotate
{
    //设置图片旋转速度
    self.pointView.transform = CGAffineTransformMakeRotation (self.num / 1.2);
}

/**
 *  更新仪表盘UvMOS值
 *
 *  @param uvMOS uvMOS值
 */
- (void)updateUvMOS:(float)uvMOS
{
    _num = -1;
    if (uvMOS != _num)
    {
        if (uvMOS < 2.5)
        {
            self.grayView.transform = CGAffineTransformMakeRotation (0 / 1.2);
        }
        if (uvMOS >= 2.5)
        {
            self.grayView.transform = CGAffineTransformMakeRotation (uvMOS - 2.5 / 1.2);
        }
        _num = uvMOS;
        _label2.text = [NSString stringWithFormat:@"%.2f", _num];
    }
}
//通过grayView的有无来实现表盘更新
//- (void)updateUvMOS:(float)uvMOS
//{
//    self.num = uvMOS;
//    if (self.num < M_PI * 2 / 3)
//    {
//        [self.grayViewSuperView insertSubview:_grayView atIndex:self.grayViewIndexInSuperView];
//        [self.label2SuperView insertSubview:_label2 atIndex:self.label2IndexInSuperView];
//    }
//    if (self.num > M_PI * 2 / 3)
//    {
//        [_grayView removeFromSuperview];
//    }
//
//    _label2.text = [NSString stringWithFormat:@"%.2f", self.num];
//    [self rotate];
//}

@end
