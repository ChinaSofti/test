//
//  SVResultCell.m
//  SPUIView
//
//  Created by 许彦彬 on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#define CornerRadius svCornerRadius (12)

#import "SVLabelTools.h"
#import "SVResultCell.h"
#import "SVSummaryResultModel.h"
#import "SVTimeUtil.h"

@interface SVResultCell ()

// 网络类型
@property (nonatomic, strong) UIImageView *imgViewType;

// 测试日期
@property (nonatomic, strong) UILabel *testDate;

// 测试时间
@property (nonatomic, strong) UILabel *testTime;

// u-Vmos
@property (nonatomic, strong) UILabel *videoMOS;

// 加载时间的label
@property (nonatomic, strong) UILabel *loadTimeLabel;

// 加载时间值
@property (nonatomic, strong) UILabel *loadTimeValue;

// 加载时间单位
@property (nonatomic, strong) UILabel *loadTimeUnit;

// 带宽的label
@property (nonatomic, strong) UILabel *bandWidthLabel;

// 带宽的值
@property (nonatomic, strong) UILabel *bandWidthValue;

// 带宽的单位
@property (nonatomic, strong) UILabel *bandWidthUnit;

@end

@implementation SVResultCell
{
    // 所选cell的tag
    int selectedTag;
}

@synthesize resultModel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                      WithTag:(int)currentTag
{
    selectedTag = currentTag;
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addUI];
    }
    return self;
}

// 类型
- (UIImageView *)imgViewType
{
    if (_imgViewType == nil)
    {
        _imgViewType = [[UIImageView alloc] init];
    }
    return _imgViewType;
}

// 时间——月日
- (UILabel *)testDate
{
    if (_testDate == nil)
    {
        _testDate = [[UILabel alloc] init];
        _testDate.frame = CGRectMake (FITWIDTH (207), FITHEIGHT (33), FITWIDTH (207), FITHEIGHT (52));
        _testDate.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _testDate.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
        _testDate.textAlignment = NSTextAlignmentCenter;
        //        _testDate.backgroundColor = [UIColor redColor];
    }
    return _testDate;
}

// 时间——时分秒
- (UILabel *)testTime
{
    if (_testTime == nil)
    {
        _testTime = [[UILabel alloc] init];
        _testTime.frame = CGRectMake (FITWIDTH (207), FITHEIGHT (85), FITWIDTH (207), FITHEIGHT (52));
        _testTime.textColor = [UIColor colorWithHexString:@"#B2000000"];
        _testTime.font = [UIFont systemFontOfSize:pixelToFontsize (30)];
        _testTime.textAlignment = NSTextAlignmentCenter;
    }
    return _testTime;
}

// U-vMOS
- (UILabel *)videoMOS
{
    if (_videoMOS == nil)
    {
        _videoMOS = [[UILabel alloc] init];
        _videoMOS.frame = CGRectMake (FITWIDTH (414), 0, FITWIDTH (207), FITHEIGHT (170));
        _videoMOS.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _videoMOS.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
        _videoMOS.textAlignment = NSTextAlignmentCenter;
    }
    return _videoMOS;
}

// 完全加载时间
- (UILabel *)loadTime
{
    if (_loadTimeLabel == nil)
    {
        _loadTimeLabel = [[UILabel alloc] init];
        _loadTimeLabel.frame = CGRectMake (FITWIDTH (621), 0, FITWIDTH (207), FITHEIGHT (170));
    }

    if (_loadTimeValue == nil)
    {
        _loadTimeValue = [[UILabel alloc] init];
        _loadTimeValue.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _loadTimeValue.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
    }

    if (_loadTimeUnit == nil)
    {
        _loadTimeUnit = [[UILabel alloc] init];
        _loadTimeUnit.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _loadTimeUnit.font = [UIFont systemFontOfSize:pixelToFontsize (30)];
    }

    [_loadTimeLabel addSubview:_loadTimeValue];
    [_loadTimeLabel addSubview:_loadTimeUnit];
    return _loadTimeLabel;
}
//带宽
- (UILabel *)bandWidth
{
    if (_bandWidthLabel == nil)
    {
        _bandWidthLabel = [[UILabel alloc] init];
        _bandWidthLabel.frame = CGRectMake (FITWIDTH (823), 0, FITWIDTH (207), FITHEIGHT (170));
    }

    if (_bandWidthValue == nil)
    {
        _bandWidthValue = [[UILabel alloc] init];
        _bandWidthValue.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _bandWidthValue.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
    }

    if (_bandWidthUnit == nil)
    {
        _bandWidthUnit = [[UILabel alloc] init];
        _bandWidthUnit.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _bandWidthUnit.font = [UIFont systemFontOfSize:pixelToFontsize (30)];
    }

    [_bandWidthLabel addSubview:_bandWidthValue];
    [_bandWidthLabel addSubview:_bandWidthUnit];
    return _bandWidthLabel;
}

// cell的框
- (UIButton *)bgdBtn
{
    if (_bgdBtn == nil)
    {
        _bgdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgdBtn.frame = CGRectMake (FITWIDTH (22), 0, kScreenW - 2 * FITWIDTH (22), FITHEIGHT (170));
        _bgdBtn.layer.cornerRadius = CornerRadius;
        _bgdBtn.layer.borderColor = [UIColor colorWithHexString:@"#DDDDDD"].CGColor;
        _bgdBtn.layer.borderWidth = FITHEIGHT (1);
        _bgdBtn.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _bgdBtn.tag = selectedTag;
        [_bgdBtn addTarget:self
                    action:@selector (bgdBtnClick:)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgdBtn;
}

- (void)bgdBtnClick:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector (toolCellClick:)])
    {
        [self.delegate toolCellClick:self];
    }
}


- (void)addUI
{
    [self.bgdBtn addSubview:self.imgViewType];

    [self.bgdBtn addSubview:self.testDate];

    [self.bgdBtn addSubview:self.testTime];

    [self.bgdBtn addSubview:self.videoMOS];

    [self.bgdBtn addSubview:self.loadTime];

    [self.bgdBtn addSubview:self.bandWidth];

    [self addSubview:self.bgdBtn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setResultModel:(SVSummaryResultModel *)_resultModel
{
    // WIFI 0  Mobile 1
    UIImage *networkTypeImage;
    if ([_resultModel.type isEqualToString:@"0"])
    {
        networkTypeImage = [UIImage imageNamed:@"ic_network_type_wifi"];
    }
    else if ([_resultModel.type isEqualToString:@"1"])
    {
        networkTypeImage = [UIImage imageNamed:@"ic_network_type_mobile"];
    }

    self.imgViewType.image = networkTypeImage;
    double width = networkTypeImage.size.width;
    double height = networkTypeImage.size.height;
    double x = (FITWIDTH (207) - width) / 2;
    double y = (FITHEIGHT (170) - height) / 2;
    _imgViewType.frame = CGRectMake (x, y, width, height);

    NSString *testTime = _resultModel.testTime;
    self.testDate.text =
    [SVTimeUtil formatDateByMilliSecond:[testTime longLongValue] formatStr:@"MM/dd"];
    self.testTime.text =
    [SVTimeUtil formatDateByMilliSecond:[testTime longLongValue] formatStr:@"HH:mm:ss"];

    // 显示指标值，-1的显示--
    float uvmos = [_resultModel.UvMOS floatValue];
    if (uvmos == -1.0f)
    {
        self.videoMOS.text = @"--";
    }
    else
    {
        self.videoMOS.text = [NSString stringWithFormat:@"%.2f", uvmos];
    }

    double totalTime = [_resultModel.loadTime doubleValue];
    if (totalTime == -1.0f)
    {
        self.loadTimeValue.text = @"--";
        self.loadTimeUnit.text = @"";
    }
    else
    {
        self.loadTimeValue.text = [NSString stringWithFormat:@"%.2f", totalTime];
        self.loadTimeUnit.text = @"s";
    }

    // 对Label重新布局
    [SVLabelTools resetLayoutWithValueLabel:self.loadTimeValue
                                  UnitLabel:self.loadTimeUnit
                                  WithWidth:FITWIDTH (207)
                                 WithHeight:FITHEIGHT (170)];

    double bandWidth = [_resultModel.bandwidth doubleValue];
    if (bandWidth == -1.0f)
    {
        self.bandWidthValue.text = @"--";
        self.bandWidthUnit.text = @"";
    }
    else
    {
        self.bandWidthValue.text = [NSString stringWithFormat:@"%.2f", bandWidth];
        self.bandWidthUnit.text = @"Mbps";
    }

    // 对Label重新布局
    [SVLabelTools resetLayoutWithValueLabel:self.bandWidthValue
                                  UnitLabel:self.bandWidthUnit
                                  WithWidth:FITWIDTH (207)
                                 WithHeight:FITHEIGHT (170)];
}

@end
