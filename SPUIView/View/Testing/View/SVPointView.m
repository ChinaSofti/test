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

        _grayView2 = [[SVPointView alloc]
        initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (160), FITWIDTH (280), FITWIDTH (280))];
        UIImageView *imageView32 = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView32.size = CGSizeMake (280, 280);
        imageView32.image = [UIImage imageNamed:@"clock_pointer_gray"];
        imageView32.center =
        CGPointMake (_panelView2.frame.size.width / 2, _panelView2.frame.size.height / 2);
        [_grayView2 addSubview:imageView32];

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

        _grayView3 = [[SVPointView alloc]
        initWithFrame:CGRectMake (FITWIDTH (20), FITWIDTH (160), FITWIDTH (280), FITWIDTH (280))];
        UIImageView *imageView33 = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView33.size = CGSizeMake (280, 280);
        imageView33.image = [UIImage imageNamed:@"clock_pointer_gray"];
        imageView33.center =
        CGPointMake (_panelView3.frame.size.width / 2, _panelView3.frame.size.height / 2);
        [_grayView3 addSubview:imageView33];


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
// video
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
            self.grayView.transform = CGAffineTransformMakeRotation (uvMOS / 1.2 - 2.5 / 1.2);
        }
        _num = uvMOS;
        _label2.text = [NSString stringWithFormat:@"%.2f", _num];
    }
}

// web
//开始转动方法
- (void)start2
{

    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector (rotate2)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

//转动角度,速度控制
- (void)rotate2
{
    //设置图片旋转速度
    self.pointView.transform = CGAffineTransformMakeRotation (self.num / 2.4);
}

- (void)updateUvMOS2:(float)uvMOS
{
    _num = -1;
    if (uvMOS != _num)
    {
        if (uvMOS < 5)
        {
            self.grayView2.transform = CGAffineTransformMakeRotation (0 / 2.4);
        }
        if (uvMOS >= 5)
        {
            self.grayView2.transform = CGAffineTransformMakeRotation (uvMOS / 2.4 - 5 / 2.4);
        }
        _num = uvMOS;
        _label22.text = [NSString stringWithFormat:@"%.2f", _num];
    }
}

// speed
//开始转动方法
- (void)start3
{

    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector (rotate3)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

//转动角度,速度控制
- (void)rotate3
{
    if (_num < 3) // 0-8
    {
        self.pointView.transform = CGAffineTransformMakeRotation (self.num * 0.52);
    }
    if (_num >= 3 && _num < 5) // 0-13
    {
        self.pointView.transform = CGAffineTransformMakeRotation (0.26 * (self.num - 3) + 1.56);
    }
    if (_num >= 5 && _num < 10) // 0-25
    {
        self.pointView.transform = CGAffineTransformMakeRotation (0.104 * (self.num - 5) + 2.08);
    }
    if (_num >= 10 && _num < 20) // 0-40
    {
        self.pointView.transform = CGAffineTransformMakeRotation (0.052 * (self.num - 10) + 2.6);
    }
    if (_num >= 20 && _num < 50) // 0-80
    {
        self.pointView.transform = CGAffineTransformMakeRotation (0.017 * (self.num - 20) + 3.12);
    }
    if (_num >= 50 && _num < 100) // 0-100
    {
        self.pointView.transform = CGAffineTransformMakeRotation (0.0108 * (self.num - 50) + 3.62);
    }

    // 0
    //    self.pointView.transform = CGAffineTransformMakeRotation (0);
    // 1
    //    self.pointView.transform = CGAffineTransformMakeRotation (0.52);
    // 3
    //    self.pointView.transform = CGAffineTransformMakeRotation (1.56);
    // 5
    //    self.pointView.transform = CGAffineTransformMakeRotation (2.08);   (l5-l3)/(5-3) *(self
    //    -3) + M= 0.26*(sel -3)+M//3-5
    // 10
    //    self.pointView.transform = CGAffineTransformMakeRotation (2.6);
    // 20
    //    self.pointView.transform = CGAffineTransformMakeRotation (3.12);
    // 50
    //    self.pointView.transform = CGAffineTransformMakeRotation (3.62);
    // 100
    //    self.pointView.transform = CGAffineTransformMakeRotation (4.16);
}

- (void)updateUvMOS3:(float)uvMOS
{
    _num = -1;
    if (uvMOS != _num)
    {
        if (uvMOS < 5) // 0-8
        {
            self.grayView3.transform = CGAffineTransformMakeRotation (0);
        }
        if (uvMOS >= 5 && uvMOS < 10) // 0-25
        {
            self.grayView3.transform = CGAffineTransformMakeRotation (0.104 * (uvMOS - 5));
        }
        if (uvMOS >= 10 && uvMOS < 20) // 0-40
        {
            self.grayView3.transform = CGAffineTransformMakeRotation (0.052 * (uvMOS - 10) + 0.52);
        }
        if (uvMOS >= 20 && uvMOS < 50) // 0-80
        {
            self.grayView3.transform = CGAffineTransformMakeRotation (0.017 * (uvMOS - 20) + 0.52 * 2);
        }
        if (uvMOS >= 50 && uvMOS < 100) // 0-100
        {
            self.grayView3.transform = CGAffineTransformMakeRotation (0.0108 * (uvMOS - 50) + 0.52 * 3);
        }
        _num = uvMOS;
        _label23.text = [NSString stringWithFormat:@"%.2f", _num];
    }
}
@end
