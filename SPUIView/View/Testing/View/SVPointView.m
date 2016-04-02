//
//  SVPointView.m
//  SPUIView
//
//  Created by WBapple on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//


#import "SVLabelTools.h"
#import "SVPointView.h"
#import "SVVideoTestingCtrl.h"
#import "UUBar.h"

@interface SVPointView ()
//定义转盘imageView
@property (weak, nonatomic) IBOutlet UIImageView *imgViewWheel;

@end

@implementation SVPointView
{
    NSString *testType;
}

// 根据字典内容初始化表盘
- (instancetype)initWithDic:(NSMutableDictionary *)dic
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    // 设置view大小
    [self setFrame:CGRectMake (0, FITHEIGHT (536), kScreenW, FITHEIGHT (830))];

    // 根据类型获取imageName
    testType = dic[@"testType"];
    NSString *imageName = @"clock_video_panel";
    if ([testType isEqualToString:@"web"])
    {
        imageName = @"clock_web_panel";
    }
    if ([testType isEqualToString:@"speed"])
    {
        imageName = @"clock_speed_panel";
    }

    // 初始化表盘的view
    _pointView =
    [[UIView alloc] initWithFrame:CGRectMake (FITWIDTH (125), 0, FITWIDTH (830), FITHEIGHT (830))];
    UIImageView *pointImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    pointImageView.size = CGSizeMake (FITHEIGHT (830), FITHEIGHT (830));
    pointImageView.image = [UIImage imageNamed:@"clock_pointer_blue"];
    pointImageView.center = CGPointMake (_pointView.frame.size.width / 2, _pointView.frame.size.height / 2);
    [_pointView addSubview:pointImageView];

    _panelView =
    [[UIView alloc] initWithFrame:CGRectMake (FITWIDTH (125), 0, FITWIDTH (830), FITHEIGHT (830))];
    UIImageView *panelImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    panelImageView.size = CGSizeMake (FITHEIGHT (830), FITHEIGHT (830));
    panelImageView.image = [UIImage imageNamed:imageName];
    panelImageView.center = CGPointMake (_panelView.frame.size.width / 2, _panelView.frame.size.height / 2);
    [_panelView addSubview:panelImageView];

    _middleView =
    [[UIView alloc] initWithFrame:CGRectMake (FITWIDTH (125), 0, FITWIDTH (830), FITHEIGHT (830))];
    UIImageView *middleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    middleImageView.size = CGSizeMake (FITHEIGHT (830), FITHEIGHT (830));
    middleImageView.image = [UIImage imageNamed:@"clock_middle"];
    middleImageView.center = CGPointMake (_panelView.frame.size.width / 2, _panelView.frame.size.height / 2);
    [_middleView addSubview:middleImageView];


    _grayView =
    [[SVPointView alloc] initWithFrame:CGRectMake (FITWIDTH (125), 0, FITWIDTH (830), FITHEIGHT (830))];
    UIImageView *grayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    grayImageView.size = CGSizeMake (FITHEIGHT (830), FITHEIGHT (830));
    grayImageView.image = [UIImage imageNamed:@"clock_pointer_gray"];
    grayImageView.center = CGPointMake (_panelView.frame.size.width / 2, _panelView.frame.size.height / 2);
    [_grayView addSubview:grayImageView];


    _titleLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (453), FITHEIGHT (343), FITWIDTH (174), FITHEIGHT (144))];
    _titleLabel.text = dic[@"title"];
    _titleLabel.font = [UIFont systemFontOfSize:pixelToFontsize (36)];
    _titleLabel.textColor = [UIColor colorWithHexString:@"#B2000000"];
    _titleLabel.textAlignment = NSTextAlignmentCenter;


    _valueLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (FITWIDTH (395), FITHEIGHT (604), FITWIDTH (290), FITHEIGHT (100))];
    _valueLabel.text = dic[@"defaultValue"];
    _valueLabel.textColor = [UIColor colorWithHexString:@"#29A5E5"];
    _valueLabel.font = [UIFont systemFontOfSize:pixelToFontsize (118)];
    _valueLabel.textAlignment = NSTextAlignmentCenter;

    NSString *unitStr = dic[@"unit"];
    if (unitStr)
    {
        _unitLabel = [[UILabel alloc]
        initWithFrame:CGRectMake (_valueLabel.rightX, FITHEIGHT (604), FITWIDTH (29), FITHEIGHT (100))];
        _unitLabel.text = unitStr;
        _unitLabel.textColor = [UIColor colorWithHexString:@"#29A5E5"];
        _unitLabel.font = [UIFont systemFontOfSize:pixelToFontsize (78)];
        _unitLabel.textAlignment = NSTextAlignmentCenter;
    }

    [self addSubview:_pointView];
    [self addSubview:_grayView];
    [self addSubview:_panelView];
    [self addSubview:_middleView];
    [self addSubview:_titleLabel];
    [self addSubview:_valueLabel];
    [self addSubview:_unitLabel];

    return self;
}

//开始转动方法
- (void)start
{

    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector (rotate_5)];
    if ([testType isEqualToString:@"web"])
    {
        link = [CADisplayLink displayLinkWithTarget:self selector:@selector (rotate_10)];
    }
    if ([testType isEqualToString:@"speed"])
    {
        link = [CADisplayLink displayLinkWithTarget:self selector:@selector (rotate_100)];
    }

    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

//转动角度,速度控制
- (void)rotate_5
{
    //设置图片旋转速度
    self.pointView.transform = CGAffineTransformMakeRotation (self.num / 1.2);
}

/**
 *  更新仪表盘的指标值
 *
 *  @param uvMOS uvMOS值
 */
- (void)updateValue:(float)value
{
    if ([testType isEqualToString:@"video"])
    {
        [self updateValue_5:value];
    }

    if ([testType isEqualToString:@"web"])
    {
        [self updateValue_10:value];
    }
    if ([testType isEqualToString:@"speed"])
    {
        [self updateValue_100:value];
    }

    // 自适应仪表盘的值和单位
    if (!_unitLabel)
    {
        _unitLabel = [[UILabel alloc] init];
    }

    [SVLabelTools resetLayoutWithValueLabel:_valueLabel
                                  UnitLabel:_unitLabel
                                  WithWidth:kScreenW
                                 WithHeight:FITHEIGHT (100)
                                      WithY:FITHEIGHT (604)];
}

/**
 *  更新仪表盘的指标值
 *
 *  @param uvMOS uvMOS值
 */
- (void)updateValue_5:(float)value
{
    _num = -1;
    if (value != _num)
    {
        if (value < 2.5)
        {
            self.grayView.transform = CGAffineTransformMakeRotation (0 / 1.2);
        }
        if (value >= 2.5)
        {
            self.grayView.transform = CGAffineTransformMakeRotation (value / 1.2 - 2.5 / 1.2);
        }
        _num = value;
        _valueLabel.text = [NSString stringWithFormat:@"%.2f", _num];
    }
}

//转动角度,速度控制
- (void)rotate_10
{
    //设置图片旋转速度
    self.pointView.transform = CGAffineTransformMakeRotation (self.num / 2.4);
}

- (void)updateValue_10:(float)uvMOS
{
    _num = -1;
    if (uvMOS != _num)
    {
        if (uvMOS < 5)
        {
            self.grayView.transform = CGAffineTransformMakeRotation (0 / 2.4);
        }
        if (uvMOS >= 5)
        {
            self.grayView.transform = CGAffineTransformMakeRotation (uvMOS / 2.4 - 5 / 2.4);
        }
        _num = uvMOS;
        _valueLabel.text = [NSString stringWithFormat:@"%.2f", _num];
    }
}

//转动角度,速度控制
- (void)rotate_100
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
}

- (void)updateValue_100:(float)uvMOS
{
    _num = -1;
    if (uvMOS != _num)
    {
        if (uvMOS < 5) // 0-8
        {
            self.grayView.transform = CGAffineTransformMakeRotation (0);
        }
        if (uvMOS >= 5 && uvMOS < 10) // 0-25
        {
            self.grayView.transform = CGAffineTransformMakeRotation (0.104 * (uvMOS - 5));
        }
        if (uvMOS >= 10 && uvMOS < 20) // 0-40
        {
            self.grayView.transform = CGAffineTransformMakeRotation (0.052 * (uvMOS - 10) + 0.52);
        }
        if (uvMOS >= 20 && uvMOS < 50) // 0-80
        {
            self.grayView.transform = CGAffineTransformMakeRotation (0.017 * (uvMOS - 20) + 0.52 * 2);
        }
        if (uvMOS >= 50 && uvMOS < 100) // 0-100
        {
            self.grayView.transform = CGAffineTransformMakeRotation (0.0108 * (uvMOS - 50) + 0.52 * 3);
        }
        _num = uvMOS;
        _valueLabel.text = [NSString stringWithFormat:@"%.2f", _num];
    }
}
@end
