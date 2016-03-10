//
//  SVPointView.m
//  SPUIView
//
//  Created by WBapple on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//


#import "SVPointView.h"
#import "SVVideoTestingCtrl.h"
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
        // VideoTestingView中的初始化
        _pointView = [[UIView alloc]
        initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (160), FITWIDTH (280), FITWIDTH (280))];
        UIImageView *imageView0 = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView0.size = CGSizeMake (280, 280);
        imageView0.image = [UIImage imageNamed:@"clock_pointer_blue"];
        imageView0.center = CGPointMake (_pointView.frame.size.width / 2, _pointView.frame.size.height / 2);
        [_pointView addSubview:imageView0];

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


        //        _pointView = [[[NSBundle mainBundle] loadNibNamed:@"SVPointView" owner:nil
        //        options:nil] lastObject];
        //        _pointView.center = _panelView.center;
        //        _pointView.center = CGPointMake(_panelView.frame.size.width/2,
        //        _panelView.frame.size.height/2);


        // WebTestingView中的初始化

        NSString *title1 = I18N (@"Load duration");
        _panelView2 = [[UIView alloc]
        initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (160), FITWIDTH (280), FITWIDTH (280))];
        UIImageView *imageView12 = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView12.size = CGSizeMake (280, 280);
        imageView12.image = [UIImage imageNamed:@"clock_web_panel"];
        imageView12.center =
        CGPointMake (_panelView2.frame.size.width / 2, _panelView2.frame.size.height / 2);
        [_panelView2 addSubview:imageView12];

        _label12 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (120), FITWIDTH (290), FITWIDTH (80), FITWIDTH (20))];
        _label12.text = title1;
        _label12.font = [UIFont systemFontOfSize:13.0f];
        _label12.textAlignment = NSTextAlignmentCenter;


        _label22 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (110), FITWIDTH (350), FITWIDTH (100), FITWIDTH (50))];
        _label22.text = @"0.00";
        _label22.textColor = RGBACOLOR (44, 166, 222, 1);
        _label22.font = [UIFont systemFontOfSize:36.0f];
        _label22.textAlignment = NSTextAlignmentCenter;

        _label32 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (150), FITWIDTH (355), FITWIDTH (100), FITWIDTH (50))];
        _label32.text = @"s";
        _label32.textColor = RGBACOLOR (44, 166, 222, 1);
        _label32.font = [UIFont systemFontOfSize:18.0f];
        _label32.textAlignment = NSTextAlignmentCenter;

        // SpeedTestingView中的初始化

        NSString *title2 = I18N (@"Speed");
        _panelView3 = [[UIView alloc]
        initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (160), FITWIDTH (280), FITWIDTH (280))];
        UIImageView *imageView13 = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView13.size = CGSizeMake (280, 280);
        imageView13.image = [UIImage imageNamed:@"clock_speed_panel"];
        imageView13.center =
        CGPointMake (_panelView3.frame.size.width / 2, _panelView3.frame.size.height / 2);
        [_panelView3 addSubview:imageView13];

        _label13 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (120), FITWIDTH (290), FITWIDTH (80), FITWIDTH (20))];
        _label13.text = title2;
        _label13.font = [UIFont systemFontOfSize:13.0f];
        _label13.textAlignment = NSTextAlignmentCenter;


        _label23 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (90), FITWIDTH (350), FITWIDTH (100), FITWIDTH (50))];
        _label23.text = @"0.00";
        _label23.textColor = RGBACOLOR (44, 166, 222, 1);
        _label23.font = [UIFont systemFontOfSize:36.0f];
        _label23.textAlignment = NSTextAlignmentCenter;

        _label33 = [[UILabel alloc]
        initWithFrame:CGRectMake (FITWIDTH (150), FITWIDTH (355), FITWIDTH (100), FITWIDTH (50))];
        _label33.text = @"Mbps";
        _label33.textColor = RGBACOLOR (44, 166, 222, 1);
        _label33.font = [UIFont systemFontOfSize:18.0f];
        _label33.textAlignment = NSTextAlignmentCenter;
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
