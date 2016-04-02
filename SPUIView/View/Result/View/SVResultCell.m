//
//  SVResultCell.m
//  SPUIView
//
//  Created by 许彦彬 on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//
#define CornerRadius svCornerRadius (12)

#import "SVResultCell.h"
#import "SVSummaryResultModel.h"
#import "SVTimeUtil.h"

@interface SVResultCell ()

@property (nonatomic, strong) UIImageView *imgViewType;
@property (nonatomic, strong) UILabel *testDate;
@property (nonatomic, strong) UILabel *testTime;
@property (nonatomic, strong) UILabel *videoMOS;
@property (nonatomic, strong) UILabel *loadTime;
@property (nonatomic, strong) UILabel *bandWidth;

@end

@implementation SVResultCell

@synthesize resultModel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addUI];
    }
    return self;
}
//类型
- (UIImageView *)imgViewType
{
    if (_imgViewType == nil)
    {
        _imgViewType = [[UIImageView alloc] init];
        _imgViewType.frame = CGRectMake (FITWIDTH (79), FITHEIGHT (58), kScreenW / 15, kScreenH / 28);
    }
    return _imgViewType;
}
//时间——月日
- (UILabel *)testDate
{
    if (_testDate == nil)
    {
        _testDate = [[UILabel alloc] init];
        _testDate.frame = CGRectMake (FITWIDTH (207), FITHEIGHT (30), FITWIDTH (207), FITHEIGHT (58));
        _testDate.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _testDate.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
        _testDate.textAlignment = NSTextAlignmentCenter;
        //        _testDate.backgroundColor = [UIColor redColor];
    }
    return _testDate;
}
//时间——时分秒
- (UILabel *)testTime
{
    if (_testTime == nil)
    {
        _testTime = [[UILabel alloc] init];
        _testTime.frame = CGRectMake (FITWIDTH (207), FITHEIGHT (100), FITWIDTH (207), FITHEIGHT (58));
        _testTime.textColor = [UIColor colorWithHexString:@"#B2000000"];
        _testTime.font = [UIFont systemFontOfSize:pixelToFontsize (30)];
        _testTime.textAlignment = NSTextAlignmentCenter;
        //        _testTime.backgroundColor = [UIColor redColor];
    }
    return _testTime;
}
// U-vMOS
- (UILabel *)videoMOS
{
    if (_videoMOS == nil)
    {
        _videoMOS = [[UILabel alloc] init];
        _videoMOS.frame = CGRectMake (FITWIDTH (414), FITHEIGHT (58), FITWIDTH (207), FITHEIGHT (58));
        _videoMOS.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _videoMOS.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
        _videoMOS.textAlignment = NSTextAlignmentCenter;
        //        _videoMOS.backgroundColor = [UIColor redColor];
    }
    return _videoMOS;
}

//完全加载时间
- (UILabel *)loadTime
{
    if (_loadTime == nil)
    {
        _loadTime = [[UILabel alloc] init];
        _loadTime.frame = CGRectMake (FITWIDTH (621), FITHEIGHT (58), FITWIDTH (207), FITHEIGHT (58));
        _loadTime.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _loadTime.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
        _loadTime.textAlignment = NSTextAlignmentCenter;
        //        _loadTime.backgroundColor = [UIColor redColor];
    }
    return _loadTime;
}
//带宽
- (UILabel *)bandWidth
{
    if (_bandWidth == nil)
    {
        _bandWidth = [[UILabel alloc] init];
        _bandWidth.frame = CGRectMake (FITWIDTH (823), FITHEIGHT (58), FITWIDTH (207), FITHEIGHT (58));
        _bandWidth.textColor = [UIColor colorWithHexString:@"#E5000000"];
        _bandWidth.font = [UIFont systemFontOfSize:pixelToFontsize (48)];
        _bandWidth.textAlignment = NSTextAlignmentCenter;
        //        _bandWidth.backgroundColor = [UIColor redColor];
    }
    return _bandWidth;
}

// cell的框
- (UIButton *)bgdBtn
{
    if (_bgdBtn == nil)
    {
        _bgdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgdBtn.frame = CGRectMake (FITWIDTH (24), 0, kScreenW - 2 * FITWIDTH (24), FITHEIGHT (170));
        _bgdBtn.layer.cornerRadius = CornerRadius * 2;
        _bgdBtn.layer.borderColor = [UIColor colorWithHexString:@"#dddddd"].CGColor;
        _bgdBtn.layer.borderWidth = 1;
        [_bgdBtn addTarget:self
                    action:@selector (bgdBtnClick:)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgdBtn;
}

- (void)bgdBtnClick:(UIButton *)button
{
    if (self.cellBlock)
    {
        _cellBlock ();
    }
}

- (void)addUI
{
    [self.contentView addSubview:self.bgdBtn];

    [self.bgdBtn addSubview:self.imgViewType];

    [self.bgdBtn addSubview:self.testDate];

    [self.bgdBtn addSubview:self.testTime];

    [self.bgdBtn addSubview:self.videoMOS];

    [self.bgdBtn addSubview:self.loadTime];

    [self.bgdBtn addSubview:self.bandWidth];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setResultModel:(SVSummaryResultModel *)_resultModel
{
    // WIFI 0  Mobile 1
    if ([_resultModel.type isEqualToString:@"0"])
    {
        self.imgViewType.image = [UIImage imageNamed:@"ic_network_type_wifi"];
    }
    else if ([_resultModel.type isEqualToString:@"1"])
    {
        self.imgViewType.image = [UIImage imageNamed:@"ic_network_type_mobile"];
    }

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
        self.loadTime.text = @"--";
    }
    else
    {
        self.loadTime.text = [NSString stringWithFormat:@"%.2fs", totalTime];
    }
    double bandWidth = [_resultModel.bandwidth doubleValue];
    if (bandWidth == -1.0f)
    {
        self.bandWidth.text = @"--";
    }
    else
    {
        self.bandWidth.text = [NSString stringWithFormat:@"%.2fMbps", bandWidth];
    }
}

@end
