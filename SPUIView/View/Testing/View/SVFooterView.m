//
//  SVFooterView.m
//  SpeedPro
//
//  Created by WBapple on 16/3/3.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVFooterView.h"
@implementation SVFooterView

//初始化方法
- (instancetype)init
{
    if ([super init])
    {
        NSString *title3 = I18N (@"Video server location");
        NSString *title4 = I18N (@"Resolution");
        NSString *title5 = I18N (@"Bit rate");
        // FooterView中的初始化
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
@end
